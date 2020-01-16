﻿within Buildings.Applications.DHC.Examples.FifthGeneration.UnidirectionalSeries.Agents;
model EnergyTransferStation_bck
  "Model of a substation for heating hot water and chilled water production"
  replaceable package Medium =
    Modelica.Media.Interfaces.PartialMedium
    "Medium model for water"
    annotation (choicesAllMatching = true);
  outer
    Buildings.Applications.DHC.Examples.FifthGeneration.UnidirectionalSeries.Data.DesignDataDHC
    datDes "DHC systenm design data";
  // SYSTEM GENERAL
  parameter Modelica.SIunits.HeatFlowRate QCoo_flow_nominal(
    min=Modelica.Constants.eps)
    "Design cooling thermal power (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.HeatFlowRate QHea_flow_nominal(
    min=Modelica.Constants.eps)
    "Design heating thermal power (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.TemperatureDifference dT_nominal = 5
    "Water temperature drop/increase accross load and source-side HX (always positive)"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature TChiWatSup_nominal = 273.15 + 18
    "Chilled water supply temperature"
     annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature TChiWatRet_nominal=
    TChiWatSup_nominal + dT_nominal
    "Chilled water return temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature THeaWatSup_nominal = 273.15 + 40
    "Heating water supply temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Temperature THeaWatRet_nominal=
    THeaWatSup_nominal - dT_nominal
    "Heating water return temperature"
    annotation (Dialog(group="Nominal conditions"));
  parameter Modelica.SIunits.Pressure dp_nominal(displayUnit="Pa") = 50000
    "Pressure difference at nominal flow rate (for each flow leg)"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mHeaWat_flow_nominal(min=0)=
    abs(QHea_flow_nominal / cp_default / (THeaWatSup_nominal - THeaWatRet_nominal))
    "Heating water mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mChiWat_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / (TChiWatSup_nominal - TChiWatRet_nominal))
    "Heating water mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.SpecificHeatCapacity cp_default=
    Medium.specificHeatCapacityCp(Medium.setState_pTX(
      p = Medium.p_default,
      T = Medium.T_default,
      X = Medium.X_default))
    "Specific heat capacity of the fluid";
  final parameter Boolean allowFlowReversal = false
    "= true to allow flow reversal, false restricts to design direction (port_a -> port_b)"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);
  // HEAT PUMP
  parameter Real COP_nominal(unit="1") = 5
    "Heat pump COP"
    annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TConLvg_nominal = THeaWatSup_nominal
    "Condenser leaving temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TConEnt_nominal = THeaWatRet_nominal
    "Condenser entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TEvaLvg_nominal=
    TEvaEnt_nominal - dT_nominal
    "Evaporator leaving temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature TEvaEnt_nominal = datDes.TLooMin
    "Evaporator entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mCon_flow_nominal(min=0)=
    abs(QHea_flow_nominal / cp_default / (TConLvg_nominal - TConEnt_nominal))
    "Condenser mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate mEva_flow_nominal(min=0)=
    abs(heaPum.QEva_flow_nominal / cp_default / (TEvaLvg_nominal - TEvaEnt_nominal))
    "Evaporator mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  // CHW HX
  final parameter Modelica.SIunits.Temperature T1HexChiEnt_nominal=
    datDes.TLooMax
    "CHW HX primary entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.Temperature T2HexChiEnt_nominal=
    TChiWatRet_nominal
    "CHW HX secondary entering temperature"
     annotation (Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate m1HexChi_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / dT_nominal)
    "CHW HX primary mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  final parameter Modelica.SIunits.MassFlowRate m2HexChi_flow_nominal(min=0)=
    abs(QCoo_flow_nominal / cp_default / (THeaWatSup_nominal - THeaWatRet_nominal))
    "CHW HX secondary mass flow rate"
    annotation(Dialog(group="Nominal conditions"));
  // Diagnostics
   parameter Boolean show_T = true
    "= true, if actual temperature at port is computed"
    annotation(Dialog(tab="Advanced",group="Diagnostics"));
  parameter Modelica.Fluid.Types.Dynamics mixingVolumeEnergyDynamics=
    Modelica.Fluid.Types.Dynamics.FixedInitial
    "Formulation of energy balance for mixing volume at inlet and outlet"
     annotation(Dialog(tab="Dynamics"));
  // IO CONNECTORS
  Modelica.Blocks.Interfaces.RealOutput PCom(final unit="W")
    "Power drawn by compressor"
    annotation (Placement(transformation(extent={{280,360},{320,400}}),
        iconTransformation(extent={{280,240},{320,280}})));
  Modelica.Blocks.Interfaces.RealOutput PPum(final unit="W")
    "Power drawn by pumps motors"
    annotation (Placement(transformation(extent={{280,320},{320,360}}),
        iconTransformation(extent={{280,200},{320,240}})));
  Modelica.Blocks.Interfaces.RealOutput PHea(unit="W")
    "Total power consumed for space heating"
    annotation (Placement(transformation(extent={{280,280},{320,320}}),
        iconTransformation(extent={{280,160},{320,200}})));
  Modelica.Blocks.Interfaces.RealOutput PCoo(unit="W")
    "Total power consumed for space cooling"
    annotation (Placement(transformation(extent={{280,240},{320,280}}),
        iconTransformation(extent={{280,120},{320,160}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_a(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default)) "Fluid connector a"
    annotation (Placement(transformation(extent={{-290,-10},{-270,10}}),
        iconTransformation(extent={{-300,-20},{-260,20}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_b(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default)) "Fluid connector b"
    annotation (Placement(transformation(extent={{290,-10},{270,10}}),
        iconTransformation(extent={{298,-20},{258,20}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bHeaWat(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default))
    "Fluid connector b"
    annotation (Placement(transformation(extent={{290,410},{270,430}}),
        iconTransformation(extent={{300,-140},{260,-100}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aChi(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default))
    "Fluid connector a"
    annotation (Placement(transformation(extent={{-290,-430},{-270,-410}}),
        iconTransformation(extent={{-300,-260},{-260,-220}})));
  Modelica.Fluid.Interfaces.FluidPort_b port_bChi(
    redeclare final package Medium = Medium,
    h_outflow(start=Medium.h_default))
    "Fluid connector b"
    annotation (Placement(transformation(extent={{290,-430},{270,-410}}),
        iconTransformation(extent={{300,-262},{260,-222}})));
  Modelica.Blocks.Interfaces.RealInput TSetHeaWat
    "Heating water set point"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,200}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,240})));
  Modelica.Blocks.Interfaces.RealInput TSetChiWat "Chilled water set point"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,-180}), iconTransformation(
        extent={{-20,-20},{20,20}},
        rotation=0,
        origin={-300,160})));
  // COMPONENTS
  Buildings.Fluid.Delays.DelayFirstOrder volMix_a(
    redeclare final package Medium = Medium,
    nPorts=3,
    final m_flow_nominal=(mEva_flow_nominal + m1HexChi_flow_nominal)/2,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume to break algebraic loops and to emulate the delay of the substation"
    annotation (Placement(transformation(extent={{-270,0},{-250,20}})));
  Buildings.Fluid.Delays.DelayFirstOrder volMix_b(
    redeclare final package Medium = Medium,
    nPorts=3,
    final m_flow_nominal=(mEva_flow_nominal + m1HexChi_flow_nominal)/2,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume to break algebraic loops and to emulate the delay of the substation"
    annotation (Placement(transformation(extent={{250,0},{270,20}})));
  Buildings.Fluid.HeatPumps.Carnot_TCon heaPum(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final m1_flow_nominal=mCon_flow_nominal,
    final m2_flow_nominal=mEva_flow_nominal,
    final dTEva_nominal=TEvaLvg_nominal - TEvaEnt_nominal,
    final dTCon_nominal=TConLvg_nominal - TConEnt_nominal,
    final allowFlowReversal1=false,
    final allowFlowReversal2=allowFlowReversal,
    final use_eta_Carnot_nominal=false,
    final COP_nominal=COP_nominal,
    final QCon_flow_nominal=QHea_flow_nominal,
    final dp1_nominal=dp_nominal,
    final dp2_nominal=dp_nominal)
    "Heat pump (index 1 for condenser side)"
    annotation (Placement(transformation(extent={{0,116},{-20,136}})));
  Distribution.BaseClasses.Pump_m_flow pumEva(redeclare final package Medium =
        Medium, final m_flow_nominal=mEva_flow_nominal) "Evaporator pump"
    annotation (Placement(transformation(extent={{-110,110},{-90,130}})));
  Distribution.BaseClasses.Pump_m_flow pum1HexChi(redeclare final package
      Medium = Medium, final m_flow_nominal=m1HexChi_flow_nominal)
    "Chilled water HX primary pump"
    annotation (Placement(transformation(extent={{-110,-330},{-90,-310}})));
  Modelica.Blocks.Interfaces.RealOutput mHea_flow
    "Mass flow rate used for heating (heat pump evaporator)"
    annotation ( Placement(transformation(extent={{280,200},{320,240}}),
        iconTransformation(extent={{280,80},{320,120}})));
  Modelica.Blocks.Interfaces.RealOutput mCoo_flow
    "Mass flow rate used for cooling (CHW HX primary)"
    annotation ( Placement(transformation(extent={{280,160},{320,200}}),
        iconTransformation(extent={{280,40},{320,80}})));
  Modelica.Fluid.Interfaces.FluidPort_a port_aHeaWat(
    redeclare package Medium = Medium,
    h_outflow(start=Medium.h_default))
    "Fluid connector a"
    annotation (Placement(transformation(extent={{-290,410},{-270,430}}),
        iconTransformation(extent={{-300,-140},{-260,-100}})));
  Buildings.Fluid.HeatExchangers.DryCoilEffectivenessNTU hexChi(
    redeclare final package Medium1 = Medium,
    redeclare final package Medium2 = Medium,
    final m1_flow_nominal=m1HexChi_flow_nominal,
    final m2_flow_nominal=m2HexChi_flow_nominal,
    final dp1_nominal=dp_nominal/2,
    final dp2_nominal=dp_nominal/2,
    configuration=Buildings.Fluid.Types.HeatExchangerConfiguration.CounterFlow,
    final Q_flow_nominal=QCoo_flow_nominal,
    final T_a1_nominal=T1HexChiEnt_nominal,
    final T_a2_nominal=T2HexChiEnt_nominal,
    final allowFlowReversal1=allowFlowReversal,
    final allowFlowReversal2=allowFlowReversal) "Chilled water HX"
    annotation (Placement(transformation(extent={{-20,-344},{0,-324}})));
  Buildings.Fluid.Delays.DelayFirstOrder volHeaWat(
    redeclare final package Medium = Medium,
    nPorts=5,
    final m_flow_nominal=mCon_flow_nominal,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume representing the decoupler of the HHW distribution system"
    annotation (Placement(transformation(extent={{-10,420},{10,440}})));
  Distribution.BaseClasses.Pump_m_flow pumCon(redeclare package Medium = Medium,
      final m_flow_nominal=mCon_flow_nominal) "Condenser pump"
    annotation (Placement(transformation(extent={{70,130},{50,150}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senT2HexChiLvg(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=m2HexChi_flow_nominal)
    "Chilled water supply temperature (sensed)"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-160,-340})));
  Buildings.Controls.OBC.CDL.Continuous.HysteresisWithHold hysWitHol(
    uLow=1E-4*mHeaWat_flow_nominal,
    uHigh=0.01*mHeaWat_flow_nominal,
    trueHoldDuration=0,
    falseHoldDuration=30)
    annotation (Placement(transformation(extent={{-220,270},{-200,290}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloHeaWat(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal)
    "Heating water mass flow rate (sensed)"
    annotation (Placement(transformation(extent={{-250,430},{-230,410}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai(k=mCon_flow_nominal)
    annotation (Placement(transformation(extent={{-140,270},{-120,290}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea
    annotation (Placement(transformation(extent={{-190,270},{-170,290}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai1(k=mEva_flow_nominal)
    annotation (Placement(transformation(extent={{-140,210},{-120,230}})));
  Buildings.Fluid.Delays.DelayFirstOrder volChiWat(
    redeclare final package Medium = Medium,
    nPorts=5,
    final m_flow_nominal=m2HexChi_flow_nominal,
    final allowFlowReversal=true,
    tau=600,
    final energyDynamics=mixingVolumeEnergyDynamics)
    "Mixing volume representing the decoupler of the CHW distribution system"
    annotation (Placement(transformation(extent={{-10,-420},{10,-440}})));
  Distribution.BaseClasses.Pump_m_flow pum2CooHex(redeclare package Medium =
        Medium, final m_flow_nominal=m2HexChi_flow_nominal)
    "Chilled water HX secondary pump"
    annotation (Placement(transformation(extent={{70,-350},{50,-330}})));
  Buildings.Fluid.Sensors.MassFlowRate senMasFloChiWat(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversal)
    "Chilled water mass flow rate (sensed)"
    annotation (Placement(transformation(extent={{-250,-430},{-230,-410}})));
  Buildings.Controls.OBC.CDL.Continuous.HysteresisWithHold hysWitHol1(
    uLow=1E-4*mChiWat_flow_nominal,
    uHigh=0.01*mChiWat_flow_nominal,
    trueHoldDuration=0,
    falseHoldDuration=30)
    annotation (Placement(transformation(extent={{-220,-230},{-200,-210}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea1
    annotation (Placement(transformation(extent={{-190,-230},{-170,-210}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai2(k=m1HexChi_flow_nominal)
    annotation (Placement(transformation(extent={{-140,-230},{-120,-210}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTConLvg(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=mCon_flow_nominal)
    "Condenser water leaving temperature (sensed)"
    annotation (Placement(
        transformation(
        extent={{10,-10},{-10,10}},
        rotation=0,
        origin={-44,140})));
  Buildings.Controls.OBC.CDL.Continuous.LimPID conTChiWat(
    each Ti=120,
    each yMax=1,
    each controllerType=Buildings.Controls.OBC.CDL.Types.SimpleController.PI,
    reverseAction=true,
    each yMin=0) "PI controller for chilled water supply"
    annotation (Placement(transformation(extent={{-170,-190},{-150,-170}})));
  Buildings.Controls.OBC.CDL.Continuous.Product pro
    annotation (Placement(transformation(extent={{-88,-230},{-68,-210}})));
  Buildings.Controls.OBC.CDL.Continuous.Gain gai4(k=1.1)
    annotation (Placement(transformation(extent={{-140,-270},{-120,-250}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum(nin=1)
    annotation (Placement(transformation(extent={{230,250},{250,270}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum1(nin=2)
    annotation (Placement(transformation(extent={{230,290},{250,310}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumHea(nin=2)
    "Total power drawn by pumps motors for space heating (ETS included, building excluded)"
    annotation (Placement(transformation(extent={{170,350},{190,370}})));
  Buildings.Fluid.Sources.Boundary_pT bouHea(
    redeclare final package Medium = Medium,
    nPorts=1) "Pressure boundary condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{-40,370},{-20,390}})));
  Buildings.Fluid.Sources.Boundary_pT bouChi(
    redeclare final package Medium = Medium,
    nPorts=1) "Pressure boundary condition representing the expansion vessel"
    annotation (Placement(transformation(extent={{-40,-390},{-20,-370}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum PPumCoo(nin=2)
    "Total power drawn by pumps motors for space cooling (ETS included, building excluded)"
    annotation (Placement(transformation(extent={{170,310},{190,330}})));
  Buildings.Controls.OBC.CDL.Continuous.MultiSum mulSum2(nin=2)
    annotation (Placement(transformation(extent={{230,330},{250,350}})));
  // MISCELLANEOUS VARIABLES
  Medium.ThermodynamicState sta_a=
    Medium.setState_phX(port_a.p,
      noEvent(actualStream(port_a.h_outflow)),
      noEvent(actualStream(port_a.Xi_outflow))) if show_T
    "Medium properties in port_a";
  Medium.ThermodynamicState sta_b=
    Medium.setState_phX(port_b.p,
      noEvent(actualStream(port_b.h_outflow)),
      noEvent(actualStream(port_b.Xi_outflow))) if show_T
    "Medium properties in port_b";
  Fluid.Sensors.TemperatureTwoPort senTHeaWatSup(
    redeclare final package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=mCon_flow_nominal)
    "Heating water supply temperature (sensed)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={130,420})));
  Fluid.Sensors.TemperatureTwoPort senTChiWatSup(
    redeclare package Medium = Medium,
    allowFlowReversal=allowFlowReversal,
    m_flow_nominal=m2HexChi_flow_nominal)
    "Chilled water supply temperature (sensed)" annotation (Placement(
        transformation(
        extent={{-10,-10},{10,10}},
        rotation=0,
        origin={150,-420})));
initial equation
  assert(QCoo_flow_nominal > 0,
    "In " + getInstanceName() +
    "Nominal cooling rate must be strictly positive. Obtained QCoo_flow_nominal = " +
    String(QCoo_flow_nominal));
  assert(QHea_flow_nominal > 0,
    "In " + getInstanceName() +
    "Nominal heating rate must be strictly positive. Obtained QHea_flow_nominal = " +
    String(QHea_flow_nominal));
equation
  connect(volMix_a.ports[1], port_a) annotation (Line(points={{-262.667,0},{
          -280,0}},          color={0,127,255}));
  connect(pumEva.port_a, volMix_a.ports[2])
    annotation (Line(points={{-110,120},{-240,120},{-240,0},{-260,0}},
                                                           color={0,127,255}));
  connect(port_b, volMix_b.ports[1]) annotation (Line(points={{280,0},{257.333,
          0}},  color={0,127,255}));
  connect(volHeaWat.ports[1], pumCon.port_a) annotation (Line(points={{-3.2,420},
          {-3.2,400},{80,400},{80,140},{70,140}},       color={0,127,255}));
  connect(port_aHeaWat, senMasFloHeaWat.port_a)
    annotation (Line(points={{-280,420},{-250,420}}, color={0,127,255}));
  connect(senMasFloHeaWat.port_b, volHeaWat.ports[2])
    annotation (Line(points={{-230,420},{-1.6,420}},
                                                  color={0,127,255}));
  connect(senMasFloHeaWat.m_flow, hysWitHol.u) annotation (Line(points={{-240,
          409},{-240,280},{-222,280}},
                                  color={0,0,127}));
  connect(TSetHeaWat, heaPum.TSet) annotation (Line(points={{-300,200},{20,
          200},{20,135},{2,135}},
                              color={0,0,127}));
  connect(hysWitHol.y, booToRea.u)
    annotation (Line(points={{-198,280},{-192,280}}, color={255,0,255}));
  connect(booToRea.y, gai.u)
    annotation (Line(points={{-168,280},{-142,280}}, color={0,0,127}));
  connect(gai.y, pumCon.m_flow_in) annotation (Line(points={{-118,280},{60,
          280},{60,152}},
                       color={0,0,127}));
  connect(gai1.y, pumEva.m_flow_in)
    annotation (Line(points={{-118,220},{-100,220},{-100,132}},
                                                             color={0,0,127}));
  connect(booToRea.y, gai1.u) annotation (Line(points={{-168,280},{-160,280},
          {-160,220},{-142,220}},
                          color={0,0,127}));
  connect(port_aChi, senMasFloChiWat.port_a)
    annotation (Line(points={{-280,-420},{-250,-420}}, color={0,127,255}));
  connect(senMasFloChiWat.port_b, volChiWat.ports[1])
    annotation (Line(points={{-230,-420},{-3.2,-420}},color={0,127,255}));
  connect(senMasFloChiWat.m_flow, hysWitHol1.u) annotation (Line(points={{-240,
          -409},{-240,-220},{-222,-220}},
                                    color={0,0,127}));
  connect(hysWitHol1.y, booToRea1.u)
    annotation (Line(points={{-198,-220},{-192,-220}}, color={255,0,255}));
  connect(booToRea1.y, gai2.u)
    annotation (Line(points={{-168,-220},{-142,-220}}, color={0,0,127}));
  connect(senT2HexChiLvg.T, conTChiWat.u_m) annotation (Line(points={{-160,
          -329},{-160,-192}},                color={0,0,127}));
  connect(TSetChiWat, conTChiWat.u_s) annotation (Line(points={{-300,-180},
          {-172,-180}},
                  color={0,0,127}));
  connect(gai2.y, pro.u2) annotation (Line(points={{-118,-220},{-100,-220},
          {-100,-226},{-90,-226}},
                             color={0,0,127}));
  connect(pro.y, pum1HexChi.m_flow_in)
    annotation (Line(points={{-66,-220},{-40,-220},{-40,-280},{-100,-280},{
          -100,-308}},                                      color={0,0,127}));
  connect(conTChiWat.y, pro.u1) annotation (Line(points={{-148,-180},{-100,
          -180},{-100,-214},{-90,-214}},
                                   color={0,0,127}));
  connect(gai4.y, pum2CooHex.m_flow_in) annotation (Line(points={{-118,-260},
          {60,-260},{60,-328}},
                              color={0,0,127}));
  connect(senMasFloChiWat.m_flow, gai4.u) annotation (Line(points={{-240,
          -409},{-240,-260},{-142,-260}},
                                   color={0,0,127}));
  connect(senTConLvg.port_b, volHeaWat.ports[3]) annotation (Line(points={{-54,140},
          {-60,140},{-60,400},{0,400},{0,420},{0,420}},color={0,127,255}));
  connect(PPum, PPum)
    annotation (Line(points={{300,340},{300,340}}, color={0,0,127}));
  connect(heaPum.P, PCom) annotation (Line(points={{-21,126},{-28,126},{-28,
          100},{260,100},{260,380},{300,380}},
                 color={0,0,127}));
  connect(gai1.y, mHea_flow) annotation (Line(points={{-118,220},{300,220}},
                                               color={0,0,127}));
  connect(gai4.y, mCoo_flow) annotation (Line(points={{-118,-260},{240,-260},
          {240,180},{300,180}},
                           color={0,0,127}));
  connect(mulSum.y, PCoo)
    annotation (Line(points={{252,260},{300,260}}, color={0,0,127}));
  connect(mulSum1.y, PHea)
    annotation (Line(points={{252,300},{300,300}}, color={0,0,127}));
  connect(pumCon.P, PPumHea.u[1]) annotation (Line(points={{49,149},{40,149},
          {40,260},{142,260},{142,360},{168,360},{168,361}},
                                         color={0,0,127}));
  connect(pumEva.P, PPumHea.u[2]) annotation (Line(points={{-89,129},{-89,
          128},{-80,128},{-80,160},{120,160},{120,360},{168,360},{168,359}},
                                              color={0,0,127}));
  connect(bouHea.ports[1], volHeaWat.ports[4]) annotation (Line(points={{-20,380},
          {1.6,380},{1.6,420}}, color={0,127,255}));
  connect(bouChi.ports[1], volChiWat.ports[2]) annotation (Line(points={{-20,
          -380},{0,-380},{0,-420},{-1.6,-420}},
                                         color={0,127,255}));
  connect(pum1HexChi.P, PPumCoo.u[1]) annotation (Line(points={{-89,-311},{
          160,-311},{160,320},{168,320},{168,321}},
                                          color={0,0,127}));
  connect(pum2CooHex.P, PPumCoo.u[2]) annotation (Line(points={{49,-331},{
          24,-331},{24,-332},{20,-332},{20,-220},{160,-220},{160,340},{168,
          340},{168,319}},                                      color={0,0,127}));
  connect(PPumHea.y, mulSum1.u[1]) annotation (Line(points={{192,360},{220,360},
          {220,301},{228,301}}, color={0,0,127}));
  connect(gai1.y, mulSum1.u[2]) annotation (Line(points={{-118,220},{200,
          220},{200,300},{228,300},{228,299}},           color={0,0,127}));
  connect(PPumCoo.y, mulSum.u[1]) annotation (Line(points={{192,320},{210,320},
          {210,260},{228,260}},color={0,0,127}));
  connect(PPumHea.y, mulSum2.u[1]) annotation (Line(points={{192,360},{200,360},
          {200,341},{228,341}}, color={0,0,127}));
  connect(PPumCoo.y, mulSum2.u[2]) annotation (Line(points={{192,320},{200,320},
          {200,340},{214,340},{214,339},{228,339}},
                                color={0,0,127}));
  connect(mulSum2.y, PPum)
    annotation (Line(points={{252,340},{300,340}}, color={0,0,127}));
  connect(pum1HexChi.port_b, hexChi.port_a1) annotation (Line(points={{-90,
          -320},{-80,-320},{-80,-328},{-20,-328}}, color={0,127,255}));
  connect(hexChi.port_b1, volMix_b.ports[2]) annotation (Line(points={{0,
          -328},{8,-328},{8,-320},{260,-320},{260,0}}, color={0,127,255}));
  connect(pum2CooHex.port_b, hexChi.port_a2)
    annotation (Line(points={{50,-340},{0,-340}}, color={0,127,255}));
  connect(hexChi.port_b2, senT2HexChiLvg.port_a)
    annotation (Line(points={{-20,-340},{-150,-340}}, color={0,127,255}));
  connect(volChiWat.ports[3], pum2CooHex.port_a) annotation (Line(points={{0,-420},
          {6,-420},{6,-400},{80,-400},{80,-340},{70,-340}},           color=
         {0,127,255}));
  connect(senT2HexChiLvg.port_b, volChiWat.ports[4]) annotation (Line(
        points={{-170,-340},{-200,-340},{-200,-400},{1.6,-400},{1.6,-420}},
        color={0,127,255}));
  connect(volMix_a.ports[3], pum1HexChi.port_a) annotation (Line(points={{
          -257.333,0},{-260,0},{-260,-320},{-110,-320}}, color={0,127,255}));
  connect(pumEva.port_b, heaPum.port_a2)
    annotation (Line(points={{-90,120},{-20,120}}, color={0,127,255}));
  connect(heaPum.port_b2, volMix_b.ports[3]) annotation (Line(points={{0,120},{
          220,120},{220,0},{262.667,0}},       color={0,127,255}));
  connect(heaPum.port_b1, senTConLvg.port_a) annotation (Line(points={{-20,
          132},{-30,132},{-30,140},{-34,140}}, color={0,127,255}));
  connect(pumCon.port_b, heaPum.port_a1) annotation (Line(points={{50,140},
          {40,140},{40,132},{0,132}}, color={0,127,255}));
  connect(volHeaWat.ports[5], senTHeaWatSup.port_a)
    annotation (Line(points={{3.2,420},{120,420}}, color={0,127,255}));
  connect(senTHeaWatSup.port_b, port_bHeaWat)
    annotation (Line(points={{140,420},{280,420}}, color={0,127,255}));
  connect(volChiWat.ports[5], senTChiWatSup.port_a)
    annotation (Line(points={{3.2,-420},{140,-420}}, color={0,127,255}));
  connect(senTChiWatSup.port_b, port_bChi)
    annotation (Line(points={{160,-420},{280,-420}}, color={0,127,255}));
  annotation (
  defaultComponentName="ets",
  Documentation(info="<html>
<p>
Heating hot water is produced at low temperature (typically 40°C) with a water-to-water heat pump. 
Chilled water is produced at high temperature (typically 19°C) with a heat exchanger.
</p>
<p>
The time series data are interpolated using
Fritsch-Butland interpolation. This uses
cubic Hermite splines such that y preserves the monotonicity and
der(y) is continuous, also if extrapolated.
</p>
<p>
There is a control volume at each of the two fluid ports
that are exposed by this model. These approximate the dynamics
of the substation, and they also generally avoid nonlinear system
of equations if multiple substations are connected to each other.
</p>
</html>",
  revisions="<html>
<ul>
<li>
December 12, 2017, by Michael Wetter:<br/>
Removed call to <code>Modelica.Utilities.Files.loadResource</code>.<br/>
This is for
<a href=\"https://github.com/lbl-srg/modelica-buildings/issues/1097\">issue 1097</a>.
</li>
</ul>
</html>"),
    Icon(coordinateSystem(extent={{-280,-280},{280,280}}, preserveAspectRatio=false),
     graphics={Rectangle(
        extent={{-280,-280},{280,280}},
        lineColor={0,0,127},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
      Rectangle(
        extent={{18,-38},{46,-10}},
        lineColor={255,255,255},
        fillColor={255,255,255},
        fillPattern=FillPattern.Solid),
        Text(
          extent={{-169,-344},{131,-384}},
          lineColor={0,0,255},
          textString="%name"),
        Rectangle(
          extent={{-282,-234},{280,-250}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-280,-128},{280,-112}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-280,0},{280,8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={255,0,0},
          fillPattern=FillPattern.Solid),
        Rectangle(
          extent={{-280,0},{282,-8}},
          lineColor={0,0,255},
          pattern=LinePattern.None,
          fillColor={0,0,255},
          fillPattern=FillPattern.Solid)}),
    Diagram(coordinateSystem(extent={{-280,-460},{280,460}},
          preserveAspectRatio=false), graphics={Text(
          extent={{-106,-236},{-38,-264}},
          lineColor={0,0,127},
          pattern=LinePattern.Dash,
          textString="Add minimum pump flow rate")}));
end EnergyTransferStation_bck;
