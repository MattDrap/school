function DB=createdb_tfidf(vw, num_words, idf)
   
   cnts=cellfun('length', vw);
   docids=zeros(1,sum(cnts));
   docids([1 cumsum(cnts(1:end-1))+1])=1;
   lbls = [vw{:}]; docids=cumsum(docids);

   tf=sparse(lbls, docids, idf(lbls), num_words, numel(vw));
   lengths=1./full(sqrt(sum(tf.^2)));
   DB=sparse(docids, lbls, idf(lbls).*lengths(docids), numel(vw), num_words);