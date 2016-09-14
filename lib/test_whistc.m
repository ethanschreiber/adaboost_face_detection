% Usage: test_whistc
% This utility tests whistc.mex32

types = {'double','single'};
for t=types
    %% 1. One dimensional test
    for N=100:50:200
        d = cast(rand(1,N),t{1})*20;   % data
        wi = cast(rand(1,N),t{1});      % weights
        e = 0:20;        % edges

        [w bins] = whistc(d, wi, e); % our results
        [n Rbins] = histc(d, e);    % compare to MATLAB histc

        % created reference weighted histogram
        Rw = zeros(size(e));
        for ii=1:length(e)
            Rw(ii) = sum(wi(Rbins==ii));
        end
        if any(( sqrt( sum( (single(Rw) - w).^2 , 1 ) ) ) > 1e-6)
            stem(Rw); hold on; stem(w,'+r');
            error('WHistograms mismatch!');
        end
        if any(bins ~= Rbins)
            error('bins mismatch!');
        end
        disp('.');
    end

    %% 2. Two dimensional test
    for N=[10 20 100 200]
        for M=[200 100 20 10]
            d = cast(rand(M,N),t{1})*20;   % data
            wi = cast(rand(size(d)),t{1}); % weights
            e = 0:20;        % edges

            [w1 bins1] = whistc(d, wi, e); % along first dimension
            [w1e bins1e] = whistc(d, wi, e, 1); % explicit along first dimension
            if any(w1 ~= w1e)
                error('mismatch explicit along first dimension');
            end
            if any(bins1 ~= bins1e)
                error('mismatch explicit along first dimension');
            end

            [w2 bins2] = whistc(d, wi, e, 2); % slong second dimension

            % reference along first dimension
            Rw = [];
            Rb = [];
            for r=1:M
                [Rn Rbr] = histc(d(r,:), e);
                tw = wi(r,:);
                for ii=1:length(e)
                    Rw(r,ii) = sum( tw(Rbr==ii) );
                end
                Rb(r,:) = Rbr;
            end
            if any(( sqrt( sum( (single(Rw) - w2).^2 , 1 ) ) )>1e-5)
                error('mismatch along first dimension');
            end
            if any(Rb~=bins2)
                error('mismatch along first dimension');
            end

            % reference along second dimension
            Rw = [];
            Rb = [];
            for c=1:N
                [Rn Rbc] = histc(d(:,c), e);
                tw = wi(:,c);
                for ii=1:length(e)
                    Rw(ii,c) = sum( tw(Rbc==ii) );
                end
                Rb(:,c) = Rbc;
            end
            if any(( sqrt( sum( (single(Rw) - w1).^2 , 1 ) ) )>1e-5)
                error('mismatch along first dimension');
            end
            if any(Rb~=bins1)
                error('mismatch along first dimension');
            end
            disp('.');
        end
    end
end