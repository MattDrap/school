function [ Xu Xu_verified] = corresp_get_Xu( corresp, i )
%CORRESP_GET_XU  Get scene-to-image correspondences.
%
%  [ Xu Xu_verified] = corresp_get_Xu( corresp, i )
%
%  Input:
%    corresp .. data structure with correspondence tables
%
%    i       .. camera ID
%
%  Output:
%    Xu      .. scene-to-image point correspondences for the camera i1.
%               Rows [ ... ; x u; ... ], where x is ID of a scene point and u
%               is ID of an image point in the image i.
%
%   Xu_verified .. boolean vector, size matching to Xu. Xu_verified(j) is
%               true if the correspondence Xu(i,:) has been verified
%               (in CORRESP_JOIN_CAMERA or CORRESP_VERIFY_X), false otherwise.

% (c) 2010-11-19, Martin Matousek
% Last change: $Date::                            $
%              $Revision$

Xu = corresp.Xu{i};
Xu_verified = corresp.Xu_verified{i}(:);
