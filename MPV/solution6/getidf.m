function idf=getidf(vw, num_words);

   cnts=cellfun('length', vw);
   docids=zeros(1,sum(cnts));
   docids([1 cumsum(cnts(1:end-1))+1])=1;
   df=sparse(cumsum(docids), [vw{:}], ones(1,sum(cnts)), numel(vw), num_words)>0;
   df = sum(df);
   df(df==0)=numel(vw);
   idf=log(numel(vw)./df);
