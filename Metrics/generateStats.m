function res = generateStats(overlap,motion,shape)

c = sum(overlap)/size(overlap,2);
m = sum(motion(:,2:end),2) ./ (size(motion,2)-1);
d = m(1);
e = m(2);
f = sqrt(m(3)^2 + m(4)^2);
g = sqrt(m(5)^2 + m(6)^2);
s = sum(shape(:,2:end),2) ./ (size(shape,2)-1);
h = s(1);
i = s(2);

res = [c d e f g h i];