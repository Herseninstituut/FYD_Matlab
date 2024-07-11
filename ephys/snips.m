
for i = 1:length(electrodes)
    id = str2double(electrodes(i).electrode_id);
    electrodes(i).electrode_id = append('e_', num2str(id, '%05d'));
end

for i = 1:length(electrodes)
    probe = str2double(electrodes(i).probe_id);

    electrodes(i).probe_id = append('mn_', num2str(probe-1, '%03d'));
end

for i = 1:length(electrodes)
       electrodes(i).x =  0;
       electrodes(i).y =  0;
       electrodes(i).impedance =  0;
       electrodes(i).electrode_size =  0;
end

T = struct2table(electrodes);
Tsorted = sortrows(T, 'electrode_id');
electrodes = table2struct(Tsorted);

del(bids.Electrodes & 'subject="monkeyN"')

insert(bids.Electrodes, electrodes)

channels = fetch(bids.Channels & 'subject="monkeyN"', '*');
for i = 1:length(channels)
    elec = str2double(channels(i).electrode_id);
    channels(i).electrode_id = append('e_', num2str(elec, '%05d'));
end

for i = 1:length(channels)
    chan = str2double(channels(i).channel_id);
    channels(i).channel_id = num2str(chan, '%04d');
end

del(bids.Channels & 'subject="monkeyN"')
insert(bids.Channels, channels)