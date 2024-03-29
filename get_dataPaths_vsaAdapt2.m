function [dataPaths] = get_dataPaths_vsaAdapt2(session)
%GET_DATAPATHS_VSAADAPT2  Get datapaths for the vsaAdapt2 experiment.
%SESSION can be 'adapt' or 'null' (or leave blank for the parent directory)

if nargin < 1, session = []; end

svec = [47 79 81 87 97 ...
    121 176 183 184 185 ...
    186 188 191 194 195 ...
    196 197 201 202 204 ...
    208 209 210 211 216];
dataPaths = get_acoustLoadPaths('vsaAdapt2',svec,session);
