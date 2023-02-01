function outStr = pivot_string(inputStr, pivotPt)

ip = string(inputStr);

split_str = cellfun(@(e) split(e, pivotPt), ip, 'UniformOutput', false);
outStr = cellfun(@(e) [e{2} pivotPt e{1}],split_str,'UniformOutput',false);


end