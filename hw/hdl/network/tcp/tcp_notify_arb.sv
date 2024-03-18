/**
  * Copyright (c) 2021, Systems Group, ETH Zurich
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * 1. Redistributions of source code must retain the above copyright notice,
  * this list of conditions and the following disclaimer.
  * 2. Redistributions in binary form must reproduce the above copyright notice,
  * this list of conditions and the following disclaimer in the documentation
  * and/or other materials provided with the distribution.
  * 3. Neither the name of the copyright holder nor the names of its contributors
  * may be used to endorse or promote products derived from this software
  * without specific prior written permission.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
  * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
  * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
  * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */

`timescale 1ns / 1ps

import lynxTypes::*;

module tcp_notify_arb (
    // HOST 
    metaIntf.s                          s_notify,

    metaIntf.m                          m_notify_opened,
    metaIntf.m                          m_notify_recv, 

    input  logic    					aclk,    
	input  logic    					aresetn
);

metaIntf #(.STYPE(tcp_notify_t)) notify_opened ();
metaIntf #(.STYPE(tcp_notify_t)) notify_recv ();

// DP
always_comb begin
    s_notify.ready = 1'b0;

    notify_opened.valid = 1'b0;
    notify_recv.valid = 1'b0;

    if(s_notify.valid) begin
        if(s_notify.data.opened) begin
            notify_opened.valid = 1'b1;
            s_notify.ready = notify_opened.ready;
        end
        else begin
            notify_recv.valid = 1'b1;
            s_notify.ready = notify_recv.ready;
        end
    end
end

assign notify_opened.data = s_notify.data;
assign notify_recv.data = s_notify.data;

meta_reg #(.DATA_BITS($bits(tcp_notify_t))) inst_reg_0  (.aclk(aclk), .aresetn(aresetn), .s_meta(notify_opened), .m_meta(m_notify_opened));
meta_reg #(.DATA_BITS($bits(tcp_notify_t))) inst_reg_1  (.aclk(aclk), .aresetn(aresetn), .s_meta(notify_recv), .m_meta(m_notify_recv));
    
endmodule