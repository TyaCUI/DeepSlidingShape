function sp = ucm2seg(filename,threshold)
%threshold = 0.35;
load(filename);
sp = bwlabel(ucm2 < threshold);
sp = sp(2:2:end, 2:2:end);
end