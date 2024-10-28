function r = popj(arr,j,mode)
%将数组中的第j个元素弹出至数组头部-0或尾部-1
switch mode
    case 1
        for k = j:length(arr)-1
            temp = arr(k);
            arr(k) = arr(k+1);
            arr(k+1) = temp;
        end
    case 0
        for k = j:-1:2
            temp = arr(k);
            arr(k) = arr(k-1);
            arr(k-1) = temp;
        end
end
r = arr;
end