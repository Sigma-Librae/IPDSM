function result = findConsecutiveLogical(vector)
arguments
  vector (:,1) logical
end
    % If the entire vector is true
    if all(vector)
      result = [1,length(vector)];
      return
    end
    
    % If the entire vector is false
    if all(~vector)
      result = [];
      return
    end

    % Find the indices where the vector changes from 0 to 1 or 1 to 0
    idx = [0; diff(vector); 0];
    starts = find(idx == 1);
    ends = find(idx == -1) - 1;

    % If the last element of vector is one, add the last index value to
    % ends
    if length(ends)<length(starts)
      ends = [ends;length(vector)];
    end

    % Create the result matrix
    result = [starts, ends];

    
end