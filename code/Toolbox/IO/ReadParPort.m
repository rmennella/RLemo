function [data] = ReadParPort()

global PAR_PORT
if isempty(PAR_PORT)
    error('Parallel port interface not open.');
end

if PAR_PORT == 1
    data = Matport('Inp',889);
else
    data = 0;
end

end