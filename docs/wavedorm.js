//opcode fetch
{signal: [
  {name:'cycle', wave: '234', data:['T0','T1','T2']},
  {name: 'clk', wave: 'n..'},
  {name: 'addr', wave: '2.3', data: ['00','01']},
  {name: 'data', wave: 'z2x',data:['OPC','ARG']},
  {name: 'OE_M', wave: '01x'},
  {name: 'mem', wave: 'x2.x',data:['OPC','ARG'], phase: 0.5},
  {name: 'WE_IR0', wave: '010'},
  {name: 'IR0', wave: 'x.2.',data:['OPC'], phase: 0.5},
  {name: 'PC_INR', wave: '01x'},
  {name: 'PC0', wave: '2.3x',data:['00','01'], phase: 0.5},
],  head:{
   text:'OPCODE FETCH',
 },
  config: { hscale: 1 }
}

//MOV_A_B
{signal: [
  {name:'cycle', wave: '222', data:['T0','T1','T2']},
  {name: 'clk', wave: 'n..'},
  {name: 'addr', wave: '2.2', data: ['00','01','02']},
  {name: 'data', wave: 'z63z',data:['OPC','DATA']},
  ['RAM',
   	{name: 'OE_M', wave: '010'},
    {name: 'mem', wave: 'x6.x',data:['OPC','DATA'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010'},
  	{name: 'IR0', wave: 'x.6.',data:['OPC'], phase: 0.5},
  ],
  {name: 'PC_INR', wave: '010'},
  {name: 'PC0', wave: '2.2.',data:['00','01'], phase: 0.5},
  ['A reg',
   	{name: 'OE_A', wave: '0.1'},
    {name: 'A', wave: '3...',data:['DATA'], phase: 0.5},
  ],
  ['B reg',
  	{name: 'WE_B', wave: '0.1'},
  	{name: 'B', wave: 'x..3',data:['DATA'], phase: 0.5},
  ],   
],  head:{
   text:'MOV_A_B',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}
//LDA DATA
{signal: [
  {name:'cycle', wave: '2222', data:['T0','T1','T2','T3']},
  {name: 'clk', wave: 'n...'},
  {name: 'addr', wave: '2.2.', data: ['00','01','02']},
  {name: 'data', wave: 'z6z3',data:['LDA','DATA']},
  ['RAM',
   	{name: 'OE_M', wave: '0101'},
    {name: 'mem', wave: 'x6.3.',data:['LDA','DATA'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010.'},
  	{name: 'IR0', wave: 'x.6..',data:['LDA'], phase: 0.5},
  ],
  {name: 'PC_INR', wave: '0101'},
  {name: 'PC0', wave: '2.2.2',data:['00','01','02'], phase: 0.5},
  ['A reg',
   	{name: 'WE_A', wave: '0..1'},
    {name: 'A', wave: 'x...3',data:['DATA'], phase: 0.5},
  ],  
],  head:{
   text:'LDA DATA',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}

//MOV_MEM_A
{signal: [
  {name:'cycle', wave: '22222', data:['T0','T1','T2','T3', 'T0']},
  {name: 'clk', wave: 'n....'},
  {name: 'addr', wave: '2.8.2', data: ['00','F0','01']},
  {name: 'data', wave: 'z6z3z',data:['MOV','DATA']},
  ['RAM',
   	{name: 'OE_M', wave: '01010'},
    {name: 'mem', wave: 'x6.3.6',data:['MOV','DATA'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010..'},
  	{name: 'IR0', wave: 'x.6...',data:['MOV'], phase: 0.5},
  ],
  ['Address regs',
  {name: 'PC_INR', wave: '010..'},
  {name: 'PC0', wave: '2.2...',data:['00','01','02'], phase: 0.5},
  {name: 'AR0', wave: '8.....',data:['F0'], phase: 0.5},
  {name: 'OE_PC', wave: '1.0.1'},
  ],
  ['A reg',
   	{name: 'WE_A', wave: '0..10'},
    {name: 'A', wave: 'x...3.',data:['DATA'], phase: 0.5},
  ],  
],  head:{
   text:'MOV_MEM_A',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}


//ALU
{signal: [
  {name:'cycle', wave: '222', data:['T0','T1','T2','T3']},
  {name: 'clk', wave: 'n..'},
  {name: 'addr', wave: '2.2', data: ['00','01','02']},
  {name: 'data', wave: 'z6z',data:['INC','DATA']},
  ['RAM',
   	{name: 'OE_M', wave: '010'},
    {name: 'mem', wave: 'x6.3',data:['INC','OPC'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010'},
  	{name: 'IR0', wave: 'x.6.',data:['INC'], phase: 0.5},
  ],
  ['addr',
  {name: 'PC_INR', wave: '010'},
  {name: 'PC0', wave: '2.2.',data:['00','01','02'], phase: 0.5},

  ],
  ['ALU',
    {name: 'A', wave: '2..7',data:['02','03'], phase: 0.5},
   {name: 'sign', wave: '0...',data:['02','03'], phase: 0.5},
   {name: 'zero', wave: '0...',data:['02','03'], phase: 0.5},
   {name: 'parity', wave: '0..1',data:['02','03'], phase: 0.5},
   {name: 'carry', wave: '0...',data:['02','03'], phase: 0.5},
  ],  
],  head:{
   text:'INC',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}


//JMP
{signal: [
  {name:'cycle', wave: '22222', data:['T0','T1','T2','T3','T0']},
  {name: 'clk', wave: 'n....'},
  {name: 'addr', wave: '2.2.3', data: ['00','01','ADDR']},
  {name: 'data', wave: 'z6z3z',data:['JMP','ADDR']},
  ['RAM',
   	{name: 'OE_M', wave: '01010'},
    {name: 'mem', wave: 'x6.3.',data:['JMP','ADDR'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010..'},
  	{name: 'IR0', wave: 'x.6..',data:['JMP'], phase: 0.5},
  ],
  ['addr',
  {name: 'PC_INR', wave: '010..'},
  {name: 'WE_PC', wave: '0..10'},
  {name: 'PC0', wave: '2.2.3',data:['00','01','ADDR'], phase: 0.5},

  ],
 
],  head:{
   text:'JMP ADDR',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}

//JMP
{signal: [
  {name:'cycle', wave: '22222', data:['T0','T1','T2','T3','T0']},
  {name: 'clk', wave: 'n....'},
  {name: 'addr', wave: '2.2.3', data: ['00','01','ADDR']},
  {name: 'data', wave: 'z6z3z',data:['JMP','ADDR']},
  ['RAM',
   	{name: 'OE_M', wave: '01010'},
    {name: 'mem', wave: 'x6.3.',data:['JMP','ADDR'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010..'},
  	{name: 'IR0', wave: 'x.6..',data:['JMP'], phase: 0.5},
  ],
  ['addr',
  {name: 'PC_INR', wave: '010..'},
  {name: 'WE_PC', wave: '0..10'},
  {name: 'PC0', wave: '2.2.3',data:['00','01','ADDR'], phase: 0.5},

  ],
 
],  head:{
   text:'JMP ADDR',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}


//Conditional branch: JZ
{signal: [
  {name:'cycle', wave: '22222', data:['T0','T1','T2','T3','T0']},
  {name: 'clk', wave: 'n....'},
  {name: 'addr', wave: '2.2.3', data: ['00','01','ADDR']},
  {name: 'data', wave: 'z6z3z',data:['JZ','ADDR']},
  ['RAM',
   	{name: 'OE_M', wave: '01010'},
    {name: 'mem', wave: 'x6.3.',data:['JZ','ADDR'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010..'},
  	{name: 'IR0', wave: 'x.6..',data:['JZ'], phase: 0.5},
  ],
  ['addr',
  {name: 'PC_INR', wave: '010..'},
  {name: 'WE_PC', wave: '0..10'},
  {name: 'PC0', wave: '2.2.3',data:['00','01','ADDR'], phase: 0.5},
  ],
  ['ALU',
  {name: 'zero', wave: '0.1.0'},

  ],
 
],  head:{
   text:'JZ ADDR',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}

//JZ: FAIL
{signal: [
  {name:'cycle', wave: '2222', data:['T0','T1','T2','T0','T0']},
  {name: 'clk', wave: 'n...'},
  {name: 'addr', wave: '2.23', data: ['00','01','02']},
  {name: 'data', wave: 'z6z.',data:['JZ','ADDR']},
  ['RAM',
   	{name: 'OE_M', wave: '010.'},
    {name: 'mem', wave: 'x6.46',data:['JZ','ADDR','OPC'], phase: 0.5},
  ],
  ['IR0',
  	{name: 'WE_IR0', wave: '010.'},
  	{name: 'IR0', wave: 'x.6..',data:['JZ'], phase: 0.5},
  ],
  ['addr',
  {name: 'PC_INR', wave: '01.0'},
  {name: 'WE_PC', wave: '0...'},
  {name: 'PC0', wave: '2.23.',data:['00','01','02'], phase: 0.5},
  ],
  ['ALU',
  {name: 'zero', wave: '0.0.'},

  ],
 
],  head:{
   text:'JZ ADDR: FAIL',
     tock:1,
   	 every:1
 },
  config: { hscale: 1 }
}


