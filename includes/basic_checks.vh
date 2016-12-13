// =======================================================
// Returns 8-bit FSR. An FSR of 0 means all is well.
// =======================================================
function [7:0] section_fsr (
input           user,           // User mode.
input           rd,             // Read request.
input           wr,             // Write request.        
input [1:0]     sr,             // SR bits.
input [31:0]    dac_reg,        // DAC register.
input [SECTION_TLB_WDT-1:0] tlb // TLB entry.
);
reg [3:0] apsr;
reg [1:0] dac;
begin
        apsr = {tlb[`SECTION_TLB__AP], sr};
        dac  = (dac_reg >> ( tlb[`SECTION_TLB__DAC_SEL] << 1 )); 

        case (dac)
                DAC_MANAGER: section_fsr = 0; // No fault.
                DAC_CLIENT:  section_fsr = is_apsr_ok(user,rd,wr,apsr) ? 0 : {tlb[`SECTION_TLB__DAC_SEL], FSR_SECTION_PERMISSION_FAULT}; // Check perms.
                default:     section_fsr = {tlb[`SECTION_TLB__DAC_SEL], FSR_SECTION_DOMAIN_FAULT};  // No acc, reserved.
        endcase
end
endfunction

// =========================================================
// Returns 8-bit FSR, 0 means all is well.
// =========================================================
function [7:0] spage_fsr (
input   [1:0]   ap_sel,         // Select one of 4 APs.
input           user,           // User mode.
input           rd,             // Read request.
input           wr,             // Write request.        
input [1:0]     sr,             // SR bits.
input [31:0]    dac_reg,        // DAC register.
input [SPAGE_TLB_WDT-1:0] tlb // TLB entry.
);
reg [3:0] apsr;
reg [1:0] dac;
begin
        apsr[3:2] = tlb[`SPAGE_TLB__AP] >> (ap_sel << 1);
        apsr[1:0] = sr;
        dac  = dac_reg >> ( tlb[`SPAGE_TLB__DAC_SEL] << 1 ); 

        case (dac)
                DAC_MANAGER: spage_fsr = 0; // No fault.
                DAC_CLIENT:  spage_fsr = is_apsr_ok(user,rd,wr,apsr) ? 0 : {tlb[`SPAGE_TLB__DAC_SEL], FSR_PAGE_PERMISSION_FAULT}; // Check perms.
                default:     spage_fsr = {tlb[`SPAGE_TLB__DAC_SEL], FSR_PAGE_DOMAIN_FAULT};    
        endcase
end
endfunction

// ==========================================================
// Returns 8-bit FSR, 0 means all is well.
// ==========================================================
function [7:0] lpage_fsr (
input   [1:0]   ap_sel,         // Select one of 4 APs.
input           user,           // User mode.
input           rd,             // Read request.
input           wr,             // Write request.        
input [1:0]     sr,             // SR bits.
input [31:0]    dac_reg,        // DAC register.
input [LPAGE_TLB_WDT-1:0] tlb // TLB entry.
);
reg [3:0] apsr;
reg [1:0] dac;
begin
        apsr[3:2] = tlb[`LPAGE_TLB__AP] >> (ap_sel << 1);
        apsr[1:0] = sr;
        dac  = dac_reg >> ( tlb[`LPAGE_TLB__DAC_SEL] << 1 ); 

        case (dac)
                DAC_MANAGER: lpage_fsr = 0; // No fault.
                DAC_CLIENT:  lpage_fsr = is_apsr_ok(user,rd,wr,apsr) ? 0 : {tlb[`LPAGE_TLB__DAC_SEL], FSR_PAGE_PERMISSION_FAULT}; // Check perms.
                default:     lpage_fsr = {tlb[`LPAGE_TLB__DAC_SEL], FSR_PAGE_DOMAIN_FAULT};    
        endcase
end
endfunction


// =====================================
// 1 is OK, 0 is fail.
// =====================================
function is_apsr_ok ( input user, input rd, input wr, input [3:0] apsr);
reg x;
begin
        x = 0; // Assume fail.

        casez (apsr)
                APSR_NA_NA: x = 0;
                APSR_RO_RO: x = !wr;
                APSR_RO_NA: x = !user && rd;
                APSR_RW_NA: x = !user;
                APSR_RW_RO: x = !user | (user && rd);
                APSR_RW_RW: x = 1; // Grant.
                default   : x = 0;
        endcase

        is_apsr_ok = x;
end
endfunction
