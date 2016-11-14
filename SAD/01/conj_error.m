% computes error of "conjunction" on "examples"
function error = conj_error(conjunction, examples, labels)

error = 0;
for i = 1:size(examples, 1)
    if conj_classify(conjunction, examples(i,:)) ~= labels(i)
        error = error + 1;
    end
end