%INIT
K = [  4.30662478e+03,   0.00000000e+00,   2.59136950e+03 / 2;
      0,   4.32151461e+03,   1.42629560e+03 / 2 ;
      0,   0,   1];
  
addpath('../p5');
addpath('../TDV2');
addpath('../Misc');
addpath('../TDV3');
addpath('../toolbox');
addpath('../ba');
addpath('../corresp')
addpath('../p3p');

if( ~exist( 'p5gb', 'file' ) )
  error( 'Cannot find five-point estimator. Probably PATH is not set.' );
end

%load point / descriptors
load('UAll.mat');
%%
%Pick middle in images
pick1 = 7;
pick2 = 8;

%Compute first pair of cameras
load('Corr.mat');
u = matchmatrix{pick1, pick2};
num_cameras = 12;
[R, t,F,inl] = ransac_e(matchmatrix{pick1, pick2}, K, 2.5, 0.9);
P1 = [eye(3,3), zeros(3,1)];
P2 = R*[eye(3,3), t];
%%
cameraSet = cell(12, 1);
cameraAppendNum = [pick1; pick2];
cameraSet{pick1} = P1;
cameraSet{pick2} = P2;
%Compute 3D points
u1 = e2p(u(1:2, :));
u2 = e2p(u(3:4, :));

Xall = Pu2X(K*P1, K*P2, u1, u2);
X = Xall(:, inl);
Xcloud = p2e(X);

u1 = K * P1 * Xall;
u2 = K * P2 * Xall;
n_inl = sum(inl);

Xid_start = 1;
Xid_end = n_inl;

Xu = {[(1:n_inl)', find(inl)'], [(1:n_inl)', find(inl)']};

U = {p2e(u1); p2e(u2)};
%Bundle adjustment
[ Rt, X ] = RtXun_ba( {cameraSet{[pick1, pick2]}}, K, Xcloud, U, Xu );
cameraSet{pick1} = Rt{1};
cameraSet{pick2} = Rt{2};
Xcloud = X;

%%
%correspondence start

corresp = corresp_init(num_cameras);
for i = 1:num_cameras - 1
    for j = (i + 1):num_cameras
        corresp = corresp_add_pair( corresp, i, j, matchmatrix2{i,j}' );
    end
end
%%
xid = Xid_start:Xid_end;
Xid_start = Xid_end + 1;
% IDs of the reconstructed scene points
corresp = corresp_start( corresp, pick1, pick2, find(inl), xid );

%%
while(true)
    % list of cameras with tentative scene-to-image correspondences
    ig = corresp_get_green_cameras( corresp );
    if isempty(ig)
        break;
    end
    % counts of tentative correspondences in each `green' camera
    Xucount = corresp_get_Xucount( corresp, ig );
    [~, Xucount_ind] = max(Xucount);
    i = ig(Xucount_ind); % select the camera to be attached, based e.g. on the Xucount
    cameraAppendNum(end + 1) = i;
    Xu = corresp_get_Xu( corresp, i );
    % get scene-to-image correspondences
    U = U_all{i};

    Xw = Xcloud(:, Xu(:, 1));
    u = U(:, Xu(:, 2));
    [R, t, inl] = ransac_p3p(Xw, u, K, 2.5, 0.95);
    cameraSet{i} = [R, t];
    
    %Obtain the i-th camera pose (R;t) and a set of inliers using the scene-to-image correspondences in Xu.
    xinl = find(inl);
    
    % obtained inliers - indices to Xu{i}
    corresp = corresp_join_camera( corresp, i, xinl );

    %%
    ilist = corresp_get_cneighbours( corresp, i ); % List of cameras in the cluster that are re-
    %lated to the attached camera by some image-to-image correspondences.
    for icam = 1:size(ilist, 2)
        ic = ilist(icam); % a camera in the neighbourhood (must be iterated through ilist).
        m = corresp_get_m( corresp, i, ic ); % get remaining image-to-image correspondences
        U2 = U_all{ic};
        u = e2p( U(:, m(:, 1)) );
        u2 = e2p( U2(:, m(:, 2)) );

        Xall_icam = Pu2X(K*cameraSet{i}, K*cameraSet{ic}, u, u2);
        
        proj_x1 =  K*cameraSet{i} * Xall_icam;
        inl1 = proj_x1(3, :) > 0;
        proj_x2 =  K*cameraSet{ic} * Xall_icam;
        inl2 = proj_x2(3, :) > 0;
        
        %Proj err TODO?
        
        pre_inl = inl1 & inl2;
        inl = find(pre_inl);
        
        Xid_end = Xid_start + size(inl, 2) - 1;
        xid = Xid_start:Xid_end;
        Xid_start = Xid_end + 1;

        Xcloud = [Xcloud, p2e(Xall_icam(:, pre_inl))];
        corresp = corresp_new_x( corresp, i, ic, inl, xid );
    end
    
    ilist = corresp_get_selected_cameras( corresp ); % list of all cameras in the cluster
    for icam = 1:size(ilist, 2)
        ic = ilist(icam); % a camera in the cluster (must be iterated through ilist ).
        [Xu, Xu_verified] = corresp_get_Xu( corresp, ic );
        Xu_tentative = find( ~Xu_verified );
        % TODO: Verify (by reprojection error) scene-to-image correspondences in Xu_tentative. 
        %A subset of good points is obtained.
        U = U_all{ic};
        X = Xcloud( :, Xu(Xu_tentative, 1));
        U_ind = Xu(Xu_tentative, 2);
        
        u = U(:, U_ind);
        proj_X = K*cameraSet{ic} * e2p(X);
        
        e = sum( ( u - p2e(proj_X) ).^2 );
        inl = e < 6;
        corr_ok = Xu_tentative(inl); % The subset of good points|there is no one here.
        corresp = corresp_verify_x( corresp, ic, corr_ok );
        
    end
    [ Rt, X ] = RtXun_ba( cameraSet(corresp.camsel), K, Xcloud, U_all(corresp.camsel), corresp.Xu(corresp.camsel));
    cameraSet(corresp.camsel) = Rt;
    Xcloud = X;
    corresp = corresp_finalize_camera( corresp );
end

%%
figure;
hold on;
for i = 1:length(cameraAppendNum)
    P = cameraSet{cameraAppendNum(i)};
    C = -P(:, 1:3)' * P(:, 4);
    ViewDir = P(3, 1:3);
    plot3([C(1) ViewDir(1)], [C(2) ViewDir(2)], [C(3) ViewDir(3)], 'k');
    plot3([C(1)], [C(2)], [C(3)], 'bo');
end