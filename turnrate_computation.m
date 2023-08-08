function [w] = turnrate_computation(x,y,dt)


for i=1:length(x)-1

    v1 = [x(i),y(i)]';
    v2 = [x(i+1),y(i+1)]';
    h = v2-v1;

    D(i) = norm(h,'fro');

    if D(i) <=1e-4

        costheta(i,1) = 0;
        sintheta(i,1) = 1;

    else

        costheta(i,1) = h(1);
        sintheta(i,1) = h(2);


    end
end


%% turn rate calculation
posonCircle = [costheta,sintheta];

for k = 1 : length(costheta)-1

    vecC = posonCircle(k:k+1,:);
    v1 = vecC(1,:);
    v2 = vecC(2,:);

    deltaPhi = atan2(det([v1',v2']),dot(v1,v2));

    deltaPhi = wrapToPi(deltaPhi);

    WG(k) = deltaPhi/dt;
end

w = WG;
wmax = 80; % cap on turn rate to remove noise induced spikes due to derivative computations
w(abs(w)>wmax) = NaN; w = fillmissing(w,'next');

if sum(isnan(w))~=0
    w = fillmissing(w,'linear');
end


end
