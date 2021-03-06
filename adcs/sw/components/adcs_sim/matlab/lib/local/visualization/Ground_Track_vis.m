function Ground_Track_vis(block)
    setup(block)
end

%
% Called when the block is added to a model.
function setup(block)
  %
  % 1 input port, no output ports
  block.NumInputPorts  = 1;
  block.NumOutputPorts = 0;
  %
  % Setup functional port properties
  block.SetPreCompInpPortInfoToDynamic;
  %
  % The input is a vector of 2 angles
  block.InputPort(1).Dimensions = 2;
  %
  % Register block methods
  block.RegBlockMethod('Start',   @Start);
  block.RegBlockMethod('Outputs', @Output);
  %
  % To work in external mode
  block.SetSimViewingDevice(true);
end
%
% Called when the simulation starts.
function Start(block)
  %
  % Check to see if we already have an instance of DoublePendulum
  ud = get_param(block.BlockHandle,'UserData');
  if isempty(ud)
    vis = [];
  else
    vis = ud.vis;
  end
  %
  % If not, create one
  if isempty(vis) || ~isa(vis,'GroundTrack') || ~vis.isAlive
    vis = GroundTrack();
  else
    vis.clearPoints();
  end
  ud.vis = vis;
  %
  % Save it in UserData
  set_param(block.BlockHandle,'UserData',ud);
end
%
% Called when the simulation time changes.
function Output(block)
  if block.IsMajorTimeStep
    ud = get_param(block.BlockHandle,'UserData');
    vis = ud.vis;
    if isempty(vis) || ~isa(vis,'GroundTrack') || ~vis.isAlive
      return;
    end
    vis.updateSat(block.InputPort(1).Data(1), ...
    block.InputPort(1).Data(2));
  end
end