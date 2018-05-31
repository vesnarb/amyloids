function digest = getMetadata(slice_name)
[J, tok] = regexpi(slice_name, '(.*)_Series(\d+)', 'match', 'tokens', 'once');
if size(J)
    digest = {tok{1}, str2num(tok{2})};
else
    digest = {};
end
