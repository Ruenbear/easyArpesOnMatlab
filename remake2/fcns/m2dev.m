function yy = m2dev(y,del)
        yy = -delDiff(delDiff(y,del),del);
        yy = [yy(1)*ones(del,1);yy;yy(end)*ones(del,1)];
end