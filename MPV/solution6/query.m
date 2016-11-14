function [img_ids, score]=query(DB, q, idf)

   q_tf = sparse(1, double(q), idf(q), 1, size(DB,2));
   [foo, lbl, tf] = find(q_tf);
   norm_tf = tf / sqrt(sum(tf.^2));
   result = DB(:,lbl) * norm_tf(:);
   [score, img_ids] = sort(result', 'descend');