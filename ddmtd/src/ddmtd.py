from amaranth import Cat, ClockDomain, ClockSignal, DomainRenamer, Instance, Module, ResetSignal, Signal
import amaranth
from amaranth.lib.wiring import Component, In, Out

from src.deglitcher import Deglitcher
from src.fast_counter import FastCounter

class DDMTD(Component):
    def __init__(self,
                 freq = int(125e6),
                 mult = 8,
                 div = 100,
                 word_size=32,
                 timeout = 2**26,
                 ):
        super().__init__({
            'clk_a': In(1),
            'clk_b': In(1),
            'phase': Out(word_size),
            'phase_en': Out(1),
            'phase_clk': Out(1),
            'phase_rst': Out(1),
            'phase_eof': Out(1),
            })
        self.word_size = word_size
        self.freq = freq
        self.mult = mult
        self.div = div
        self.timeout = timeout

    def ports(self):
        return [
                self.clk_a,
                self.clk_b,
                self.phase,
                self.phase_en,
                self.phase_clk,
                self.phase_rst,
                self.phase_eof,
                ]

    def elaborate(self, platform):
        m = Module()

        mmcm_feedback = Signal()
        mmcm_locked = Signal()
        mmcm_clk = Signal()
        mmcm_clk_a = Signal()
        m.domains.sync = ClockDomain()
        m.submodules.mmcm = Instance(
                'MMCME2_ADV',
                p_CLKFBOUT_MULT_F = self.mult,
                p_CLKIN1_PERIOD = 1e9/self.freq,
                p_CLKOUT0_DIVIDE_F = self.div + 0.125,
                p_CLKOUT1_DIVIDE = self.div,

                i_CLKFBIN = mmcm_feedback,
                o_CLKFBOUT = mmcm_feedback,
                i_CLKINSEL = 1,
                o_LOCKED = mmcm_locked,

                i_CLKIN1 = self.clk_a,
                o_CLKOUT0 = mmcm_clk,
                o_CLKOUT1 = mmcm_clk_a,

                # Unused inputs tied to zero
                i_CLKIN2 = 0,
                i_DADDR = 0,
                i_DCLK = 0,
                i_DEN = 0,
                i_DI = 0,
                i_DWE = 0,
                i_PSCLK = 0,
                i_PSEN = 0,
                i_PSINCDEC = 0,
                i_PWRDWN = 0,
                i_RST = 0,
                )
        m.submodules += Instance(
                'BUFG',
                i_I = mmcm_clk,
                o_O = ClockSignal('sync'),
                )
        m.d.comb += ResetSignal('sync').eq(~mmcm_locked)
        m.d.comb += self.phase_clk.eq(ClockSignal('sync'))
        platform.add_clock_constraint(self.phase_clk, int(self.freq*self.mult/(self.div+0.125)))
        m.d.comb += self.phase_rst.eq(ResetSignal('sync'))
        m.d.comb += self.phase_eof.eq(0)

        mult_a = Signal()
        m.submodules.ffa = Instance(
                'FDRE',
                i_D = mmcm_clk_a,
                i_C = ClockSignal('sync'),
                o_Q = mult_a,
                i_CE = 1,
                i_R = 0,
                )
        mult_b = Signal()
        m.submodules.ffb = Instance(
                'FDRE',
                i_D = self.clk_b,
                i_C = ClockSignal('sync'),
                o_Q = mult_b,
                i_CE = 1,
                i_R = 0,
                )

        m.submodules.deglitch_a = deglitch_a = Deglitcher()
        m.d.comb += deglitch_a.sig_in.eq(mult_a)
        m.submodules.deglitch_b = deglitch_b = Deglitcher()
        m.d.comb += deglitch_b.sig_in.eq(mult_b)

        cnt = Signal(self.word_size)
        m.d.sync += cnt.eq(cnt + 1)

        ta = Signal.like(deglitch_a.median)
        t = Signal.like(cnt)

        with m.If(deglitch_a.begin_glitches):
            m.d.sync += cnt.eq(0)
        with m.If(deglitch_a.end_glitches):
            m.d.sync += ta.eq(deglitch_a.median)
        with m.If(deglitch_b.begin_glitches):
            m.d.sync += t.eq(cnt)
        with m.If(deglitch_b.end_glitches):
            m.d.sync += self.phase.eq(t - ta + deglitch_b.median)
            m.d.sync += self.phase_en.eq(True)
        with m.If(self.phase_en):
            m.d.sync += self.phase_en.eq(False)
        
        with m.If(cnt >= self.timeout):
            m.d.sync += self.phase.eq(2**self.word_size-1)
            m.d.sync += self.phase_en.eq(True)

        return m
