function [C, Xcloud, report_info] = camera_gluing( P1, P2, K, U_all, best_inl, ...
                                      camera_num, corresp, corresnpondences,...
                                      Ci, Cj, confidence )
%CAMERA_GLUING Summary of this function goes here
%   Detailed explanation goes here
C = cell(camera_num, 1);
report_info.camera_order = NaN(camera_num, 1);
C{Ci} = P1;
C{Cj} = P2;
report_info.camera_order(1:2) = [Ci Cj];

%% Normalize pts and get their reference in 3D
u1 = K\e2p(corresnpondences{Ci, Cj}(1:2,:));
u2 = K\e2p(corresnpondences{Ci, Cj}(3:4,:));
Xcloud = Pu2X(P1, P2, u1, u2);

Xcloud = e2p(p2e(Xcloud(:, best_inl)));
corresp = corresp_start(corresp, Ci, Cj, find(best_inl), 1:size(Xcloud,2));

%% Bundle Adjustment

[Rt_n, X_n] = RtXun_ba(C(corresp.camsel), K, p2e(Xcloud), U_all(corresp.camsel), corresp.Xu(corresp.camsel));
Xcloud = e2p(X_n);
C(corresp.camsel) = Rt_n;

count = 3;
% list of cameras with tentative scene-to-image correspondences
ig = corresp_get_green_cameras( corresp );

%% doing main job here
while ~isempty(ig)
    % counts of tentative correspondences in each ‘green’ camera
    Xucount = corresp_get_Xucount( corresp, ig );
    [~,temp_id_cur_camera] = max(Xucount);
    id_cur_camera = ig(temp_id_cur_camera);
    report_info.camera_order(count) = id_cur_camera;
    
    [Xu, ~] = corresp_get_Xu( corresp, id_cur_camera ); % get scene-to-image correspondences
    u_curr = e2p(U_all{id_cur_camera}(:,Xu(:,2)));
    X_3D = Xcloud(:,Xu(:,1));
    
    [R_best, t_best, inl] = ransac_p3p( K, X_3D, K\u_curr, confidence );
    C{id_cur_camera} = [R_best t_best];
    
%     [Rt_n, X_n] = RtXun_ba(C(corresp.camsel), K, p2e(Xcloud), U_all(corresp.camsel), corresp.Xu(corresp.camsel));
%     Xcloud = e2p(X_n);
%     C(corresp.camsel) = Rt_n;
    
    corresp = corresp_join_camera( corresp, id_cur_camera, inl );
    ilist = corresp_get_cneighbours( corresp, id_cur_camera ); % List of cameras in the cluster that are related
                                                   % to the attached camera by some image-to-image correspondences.
    
    % set thr for reprojection error, this is already power 2 threshold
    reproj_thr = 8;
    
    P_cur_camera = K*C{id_cur_camera};
    for rel_camera = ilist
        m = corresp_get_m( corresp, id_cur_camera, rel_camera ); % get remaining image-to-image correspondences
        u_cur_camera = e2p(U_all{id_cur_camera}(:,m(:,1)));
        u_rel_camera = e2p(U_all{rel_camera}(:,m(:,2)));
        
        P_rel_camera = K*C{rel_camera};

        % normalize points by Sampson
%         F = vgg_F_from_P(P_cur_camera, P_rel_camera);
%         [u_cur_camera, u_rel_camera] = u_correct_sampson( F, u_cur_camera, u_rel_camera );
        
        X_rel_camera = e2p(p2e(Pu2X(P_cur_camera, P_rel_camera, u_cur_camera, u_rel_camera)));
        u_cur_camera = p2e(u_cur_camera);
        u_rel_camera = p2e(u_rel_camera);
        
        z_temp1 = getDepth(P_cur_camera, X_rel_camera);
        z_temp2 = getDepth(P_rel_camera, X_rel_camera);
        
        all_in_front = (z_temp1 > 0) & (z_temp2 > 0);
        all_in_front_ind = find(all_in_front);   
        
        X_rel_camera_inl = X_rel_camera(:,all_in_front);
        u_reproj_cur_camera = p2e(P_cur_camera*X_rel_camera_inl);
        u_reproj_rel_camera = p2e(P_rel_camera*X_rel_camera_inl);
        
        err_reproj_cur_camera = calcErrReprojection(u_cur_camera(:,all_in_front), u_reproj_cur_camera);
        err_reproj_rel_camera = calcErrReprojection(u_rel_camera(:,all_in_front), u_reproj_rel_camera);
        err_reproj = err_reproj_cur_camera + err_reproj_rel_camera;
        
        reproj_inl = err_reproj <= reproj_thr;
        get_ind_for_zero = all_in_front_ind(~reproj_inl);
        all_in_front(get_ind_for_zero) = 0;
        
        newStartXcloudId = size(Xcloud,2)+1;
        inl_count = sum(all_in_front);
        newEndXcloudId = inl_count + newStartXcloudId - 1;
        xid = newStartXcloudId:newEndXcloudId;
        
        % add new pts to Xcloud
        Xcloud = [Xcloud X_rel_camera(:,all_in_front)];
        
        corresp = corresp_new_x( corresp, id_cur_camera, rel_camera, find(all_in_front), xid );
    end
    
    ilist = corresp_get_selected_cameras( corresp ); % list of all cameras in the cluster
    for rel_camera = ilist      
        [Xu, Xu_verified] = corresp_get_Xu( corresp, rel_camera );
        Xu_tentative = find( ~Xu_verified );
        
        Xcloud_tentative = Xcloud(:,Xu(Xu_tentative,1));
        u_rel_camera = U_all{rel_camera}(:,Xu(Xu_tentative,2));
        
        P_rel_camera = K*C{rel_camera};
        
        % calc reprojection error on Xu_tentative
        u_reproj = p2e(P_rel_camera*Xcloud_tentative);
        err_reproj = calcErrReprojection(u_rel_camera, u_reproj);
        
        reproj_inl = err_reproj <= reproj_thr/2;
        corr_ok = Xu_tentative(reproj_inl); % The subset of good points
        corresp = corresp_verify_x( corresp, rel_camera, corr_ok );
    end
    
    [Rt_n, X_n] = RtXun_ba(C(corresp.camsel), K, p2e(Xcloud), U_all(corresp.camsel), corresp.Xu(corresp.camsel));
    Xcloud = e2p(X_n);
    C(corresp.camsel) = Rt_n;
    
    corresp = corresp_finalize_camera( corresp );
    % get new list of cameras with tentative scene-to-image correspondences
    ig = corresp_get_green_cameras( corresp );
    count = count + 1;
end

Xcloud = p2e(Xcloud);
%% save wrl model
ge = ge_vrml( 'out.wrl' );
ge = ge_cams( ge, C, 'plot', 1 );  % P is a cell matrix containing cameras without K,
                                    % { ..., [R t], ... }
ge = ge_points( ge, Xcloud );       % Xcloud contains euclidean points (3xn matrix)
ge = ge_close( ge );

end

