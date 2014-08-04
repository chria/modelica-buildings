within Buildings.Electrical.AC.ThreePhasesUnbalanced.Examples.IEEETests.Test4NodesFeeder.UnbalancedStepUp;
model IEEE4Unbalanced_Y_D_StepUp
  "IEEE 4 node test feeder model with unbalanced load and Y - D connection (step up)"
  extends
    Buildings.Electrical.AC.ThreePhasesUnbalanced.Examples.IEEETests.Test4NodesFeeder.BaseClasses.IEEE4
    (
    final line1_use_Z_y=true,
    final line2_use_Z_y=false,
    redeclare Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors.ProbeWye
      node1,
    redeclare Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors.ProbeWye
      node2,
    redeclare Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors.ProbeDelta
      node3,
    redeclare Buildings.Electrical.AC.ThreePhasesUnbalanced.Sensors.ProbeDelta
      node4,
    final VLL_side1=12.47e3,
    final VLL_side2=24.9e3,
    final VARbase=6000e3,
    final V2_ref={7121,7147,7150},
    final V3_ref={23703,24040,23576},
    final V4_ref={23637,23995,23496},
    final Theta2_ref={-0.4,-120.3,119.5},
    final Theta3_ref={57.2,-63.6,176.1},
    final Theta4_ref={57.1,-63.8,175.9},
    loadRL(loadConn=Buildings.Electrical.Types.LoadConnection.wye_to_delta,
        use_pf_in=true));
  Buildings.Electrical.AC.ThreePhasesUnbalanced.Conversion.ACACTransformerStepUpYD
    transformer(
    VHigh=VLL_side1,
    VLow=VLL_side2,
    XoverR=6,
    Zperc=sqrt(0.01^2 + 0.06^2),
    VABase=VARbase)
    annotation (Placement(transformation(extent={{-26,0},{-6,20}})));
  Modelica.Blocks.Sources.Constant load3(k=-2375e3)
    annotation (Placement(transformation(extent={{14,76},{34,96}})));
  Modelica.Blocks.Sources.Constant load2(k=-1800e3)
    annotation (Placement(transformation(extent={{40,58},{60,78}})));
  Modelica.Blocks.Sources.Constant load1(k=-1275e3)
    annotation (Placement(transformation(extent={{60,30},{80,50}})));
  Modelica.Blocks.Sources.Constant pf1(k=0.85)
    annotation (Placement(transformation(extent={{0,-30},{20,-10}})));
  Modelica.Blocks.Sources.Constant pf2(k=0.9)
    annotation (Placement(transformation(extent={{22,-50},{42,-30}})));
  Modelica.Blocks.Sources.Constant pf3(k=0.95)
    annotation (Placement(transformation(extent={{44,-70},{64,-50}})));
equation
  connect(line1.terminal_p, transformer.terminal_n) annotation (Line(
      points={{-48,10},{-26,10}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(transformer.terminal_p, line2.terminal_n) annotation (Line(
      points={{-6,10},{12,10}},
      color={0,120,120},
      smooth=Smooth.None));
  connect(load2.y, loadRL.Pow2) annotation (Line(
      points={{61,68},{90,68},{90,10},{74,10}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(load3.y, loadRL.Pow3) annotation (Line(
      points={{35,86},{94,86},{94,4},{74,4}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(load1.y, loadRL.Pow1) annotation (Line(
      points={{81,40},{86,40},{86,16},{74,16}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pf1.y, loadRL.pf_in_1) annotation (Line(
      points={{21,-20},{58,-20},{58,-4.44089e-16}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pf2.y, loadRL.pf_in_2) annotation (Line(
      points={{43,-40},{64,-40},{64,-4.44089e-16}},
      color={0,0,127},
      smooth=Smooth.None));
  connect(pf3.y, loadRL.pf_in_3) annotation (Line(
      points={{65,-60},{70.2,-60},{70.2,-4.44089e-16}},
      color={0,0,127},
      smooth=Smooth.None));
  annotation (Diagram(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},
            {100,100}}), graphics), Documentation(revisions="<html><ul>
<li>
June 17, 2014, by Marco Bonvini:<br/>
Moved to Examples IEEE package.
</li>
<li>
June 6, 2014, by Marco Bonvini:<br/>
First implementation.
</li>
</ul>
</html>"));
end IEEE4Unbalanced_Y_D_StepUp;
