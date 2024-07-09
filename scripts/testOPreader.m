clearvars
clc

%OPR = OPreader('D:\Documents\OneDrive - UCB-O365\Storage\OPreader test');

OPR = OPreader('F:\2024 Liu Lab\Duration data + HeCAT21624__2024-02-16T15_55_35-Measurement 1');

%%

Inucl = readImage(OPR, 7, 2, 1, 1);
Icell = readImage(OPR, 7, 2, 2, 1);

Inucl = double(Inucl);
Inucl = (Inucl - min(Inucl(:)))/(max(Inucl(:)) - min(Inucl(:)));

Icell = double(Icell);
Icell = (Icell - min(Icell(:)))/(max(Icell(:)) - min(Icell(:)));

Irgb = cat(3, Inucl, Icell, zeros(size(Inucl), 'double'));

imshow(Irgb)