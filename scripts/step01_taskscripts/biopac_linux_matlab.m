function [time] = biopac_linux_matlab(channel, channel_num, state_num)
  if channel.biopac
      channel.d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
      time = GetSecs;
  else
      time = GetSecs;
      return
  end
end
