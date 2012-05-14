% BPMRF2    Belief propagation on a MRF with pairwise potentials using
%           the sum-product. 
%   The function call is NEWBEL = BPMRF2(C,PSI,T,SP,TOL,MAXITER,VERBOSE). 
%   The return value is a N x W matrix of belief probabilities where N is
%   the number of nodes and W is the number of states for a single node. 
%
%   The inputs are:
%     - C       N x N adjacency matrix, where C(i,j) = 1 if there is an 
%               edge between nodes i and j.
%     - PSI     W x W x N x N matrix of potentials, where PSI(ki,kj,i,j)
%               represents the (unnormalized) probability that latent
%               node values Xi = ki and Xj = kj will appear together. W
%               is the total number of discrete values a latent node can
%               take on. Alternatively, PSI can be a W x W matrix if the
%               potential for each edge is the same.
%     - T       N x W matrix. Entry T(i,k) designates the conditional
%               probability Pr(Yi | Xi = k), where Yi is the observation
%               at node i and Xi is the latent variable at node i.
%     - SP      If 1, use the sum-product. Otherwise, use argmax.
%     - TOL     Tolerance used to assess convergence.
%     - MAXITER The maximum number of iterations of belief propagation to
%               perform. A suggested amount is 5 x N, where N is the
%               number of latent nodes in the graphical model.
%     - VERBOSE Either 1 or 0.
%
%   This code is pulled directly from Kevin Murphy, but used simply for
%   my understanding (Feb 14, 2002).

function newBel = bpmrf (c, psi, t, sp, tol, maxIter, verbose)

  % Get the number of discrete states a latent node can take on.
  W = size(t,2);
  
  % Get the total number of observed nodes.
  N = size(t,1);
  
  % Give each edge a unique number. We will call this set of vertices
  % "vTokens". Also, we need to save a mapping from the adjacency
  % matrix to the indices of the tokens.
  vTokens    = find(c);
  V          = length(vTokens);
  v          = zeros(1, N*N);
  v(vTokens) = 1:V;
  v          = reshape(v, [N N]);
  clear vTokens 

  % Set up the potentials, "psi".
  if ndims(psi) == 2,
    psi = repmat(psi, [1 1 N N]);
  end;
  
  % Initialize and reserve storage for the messages.
  prodOfMsgs = t;
  oldBel     = prodOfMsgs;
  newBel     = zeros(N,W);
  oldMsg     = zeros(W,V);
  newMsg     = zeros(W,V);
  
  % Repeat for each node.
  for i = 1:N,
    naybrs = find(c(i,:));
    
    % Repeat for each neighbour of node i.
    for j = naybrs,
      oldMsg(:,v(i,j)) = 1/N;
    end;
  end;
  
  % Start the belief propagation.
  % Repeat until we've reached convergence or until we hit the maximum
  % number of iterations.
  converged = 0;
  for iter = 1:maxIter,

    if sp,
      newMsg = useSumProduct(N,c,v,psi,prodOfMsgs,oldMsg);
    else,
      newMsg = useArgMax(N,c,v,psi,prodOfMsgs,oldMsg);
    end;
    
    % Each node now multiplies all its incoming messages and computes its
    % local belief.
    for i = 1:N,
      naybrs = find(c(i,:));
      prodOfMsgs(i,:) = t(i,:);
      
      % Repeat for each neighbour of node i.
      for j = naybrs,
	prodOfMsgs(i,:) = prodOfMsgs(i,:) .* newMsg(:,v(j,i))';
      end;
      newBel(i,:) = prodOfMsgs(i,:) / sum(prodOfMsgs(i,:));
    end;    
    
    % Find the error and check to see if we've converged to a reasonable
    % degree. 
    err       = abs(newBel(:) - oldBel(:));
    converged = all(err < tol);
    if verbose,
      fprintf('Error at iteration %i is %f \n', iter, sum(err));
    end;
    
    % Prepare for the next iteration.
    oldMsg = newMsg;
    oldBel = newBel;
    
    if converged,
      break,
    end;
  end;
  
  if verbose,
    fprintf('Converged in %i iterations \n', iter);
  end;
  
% -------------------------------------------------------------------------
function newMsg = useSumProduct (N, c, v, psi, prodOfMsgs, oldMsg)

  % For each node send a message to each of its neighbours.
  for i = 1:N,
    naybrs = find(c(i,:));
    
    % Repeat for each neighbour of node i. Compute the produce of all
    % incoming messages except from neighbour j by dividing out the old
    % message from j from the product of all messages sent to i. Note
    % that we can replace 0's with anything.
    for j = naybrs,
      p  = prodOfMsgs(i,:)';
      m  = oldMsg(:,v(j,i));
      p  = p ./ (m + (m==0));
      nm = psi(:,:,i,j) * p;
      
      % Normalize the new messages.
      newMsg(:,v(i,j)) = nm / sum(nm);
    end;
  end;
  
% -------------------------------------------------------------------------
function newMsg = useArgMax (N, c, v, psi, prodOfMsgs, oldMsg)
  
  % For each node send a message to each of its neighbours.
  for i = 1:N,
    naybrs = find(c(i,:));
    
    % Repeat for each neighbour of node i. Compute the produce of all
    % incoming messages except from neighbour j by dividing out the old
    % message from j from the product of all messages sent to i. Note
    % that we can replace 0's with anything.
    for j = naybrs,
      p  = prodOfMsgs(i,:)';
      m  = oldMsg(:,v(j,i));
      p  = p ./ (m + (m==0));
      nm = max_mult(psi(:,:,i,j), p);
      
      % Normalize the new messages.
      newMsg(:,v(i,j)) = nm / sum(nm);
    end;
  end;
  