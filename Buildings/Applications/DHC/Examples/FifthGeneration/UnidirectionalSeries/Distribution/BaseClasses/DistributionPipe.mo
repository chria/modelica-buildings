within Buildings.Applications.DHC.Examples.FifthGeneration.UnidirectionalSeries.Distribution.BaseClasses;
model DistributionPipe
  "DHC distribution pipe"
  extends Buildings.Fluid.FixedResistances.HydraulicDiameter(
    dp(nominal=1E5),
    dh=0,
    final fac=1.1,
    final ReC=6000,
    final roughness=7E-6,
    allowFlowReversal=false,
    final linearized=false,
    final v_nominal=m_flow_nominal * 4 / (rho_default * dh^2 * Modelica.Constants.pi));
    // PE100 straight pipe
equation
  when terminal() then
    Modelica.Utilities.Streams.print(
       "Pipe nominal pressure drop per meter for '" + getInstanceName() + "' is " +
        String(integer( floor( dp_nominal / length + 0.5)))   + " Pa/m.");
  end when;
  annotation (
  DefaultComponentName="pipDis",
  Icon(graphics={
        Rectangle(
          extent={{-100,22},{100,-24}},
          lineColor={0,0,0},
          fillPattern=FillPattern.HorizontalCylinder,
          fillColor={0,140,72})}));
end DistributionPipe;
