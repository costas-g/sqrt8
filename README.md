# 8-bit Integer Square Root
VHDL design of a module that computes the integer square root.  

<!-- |        |                                       |
| ------:|:------------------------------------- |
| Input  | 8-bit unsigned integer + valid signal |
| Output | 4-bit unsigned integer + valid signal | -->
### Interface
<table>
  <tr>
    <td style="text-align:right;">Input</td>
    <td style="text-align:left;">8-bit unsigned integer + valid signal</td>
  </tr>
  <tr>
    <td style="text-align:right;">Output</td>
    <td style="text-align:left;">4-bit unsigned integer + valid signal</td>
  </tr>
</table>

## Design
We implement the [Digit-by-Digit calculation algorithm](#algorithm-binary-digit-by-digit-calculation) described in great detail below.  
We use a 4-stage pipeline, therefore the output latency is 4 clock cycles.  

Each stage computes the next MSB of the output result. 
For a more detailed but concise description of the process, see [VHDL algorithm](#vhdl-algorithm) 
after consulting the mathematical proof of the algorithm.

## Source Files Structure
- **`sqrt8.vhd`** — **Top module wrapper**  
└─ `sqrt8_stage.vhd` — Parameterized stage module  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─ `sqrt8_logic.vhd` — Combinational logic, parameterized for each stage  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;└─ `cas_unit.vhd` — Simple Controlled Addition Subtraction (CAS) module  
- **`tb_sqrt8.vhd`** — **Top testbench** with self-checking procedure  

## Implementation and Simulation Results
<!-- - Device: Zynq-7000 (xc7z020clg484-1)
- Clock period target: 10 ns
- Worst Negative Slack (WNS): 6.355 ns 
- Max frequency achieved: 250 Hz (clock period: 4 ns) -->
|          Parameter         |         Value                    |
| --------------------------:|:-------------------------------  |
| Device                     | Zynq-7000 (xc7z020clg484-1)      |
| Clock period target        | 3.330 ns                         |
| Worst Negative Slack (WNS) | 0.079 ns                         |
| Max frequency achieved     | 269 MHz (clock period: 3.710 ns) |
| Number of FFs              | 49                               |
| Number of LUTs             | 41                               |

## Algorithm: Binary Digit-by-Digit calculation
### Problem: Integer square root
Let $D$ and $Q$ be a non-negative integers. 
We want to find the maximum integer $Q$ such that 

$$ Q^2 \leq D $$

### Binary represenation
Suppose $D$ can be represented in binary using $2n$ bits.
Then $Q$ can be represented in binary using $n$ bits.
Specifically, the representation of $Q$ in binary can be expressed as: 

$$ Q=q_{n-1} 2^{n-1}+q_{n-2} 2^{n-2}+\dots+q_{0} 2^{0} \qquad(1)$$

where $q_k$ is the $k^\text{th}$ LSB of $Q$ and $q_k \in \set{0,1}$. 
We may assume that $q_k=0$ is for all $k\geq n$.  

Let $Q_k$ be an approximation of $Q$ represented as: 

$$Q_k=q_{n-1} 2^{n-1}+q_{n-2} 2^{n-2}+\dots+q_{k+1} 2^{k+1}+q_{k} 2^{k} \qquad (2)$$

It follows that $Q_k\leq Q$ for all $k\geq 0$, and that $Q_0 = Q$. 
We may, also, assume that $Q_k=0$ for all $k\geq n$.  

### Finding the next best approximation
Let $Q_k$ be our current best approximation of $Q$.
We define the *Remainder*, $R_k$, of this approximation as 

$$R_k = D - Q_k^2$$

for which $R_k \geq 0$ as we have established.  

Then, the next best approximation is 

$$Q_{k-1}=Q_k + q_{k-1} 2^{k-1} \qquad (3)$$

Therefore, if we can deduce the value of $q_{k-1}$ based solely on the current information we have with our current best approximation, we can find the next best approximation $Q_{k-1}$. Repeating this procedure in the same fashion, we can eventually find $Q_0=Q$. 

Since $q_{k-1} \in \set{0,1}$, we only have two options. It follows that 
$q_{k-1}=1$ if and only if the new $Q_{k-1}$ satisfies the requirement 
$Q_{k-1}^2\leq D$. Using eq. (3) and substituting $q_{k-1}=1$, that is if

$$\left(Q_k + 2^{k-1}\right)^2\leq D$$

Therefore, by expanding the square, we find that $q_{k-1}=1$ if and only if

$$
\begin{aligned}
D-\left(Q_k + 2^{k-1}\right)^2 &\geq 0 \\
D-Q_k^2 - 2Q_k 2^{k-1} - 2^{2\left(k-1\right)} &\geq 0 \\
D-Q_k^2 - \left(2^kQ_k + 2^{2k-2}\right) &\geq 0 \\
R_k - \left(2^kQ_k + 2^{2k-2}\right) &\geq 0 
\end{aligned}
$$

However, if $R_k - \left(2^kQ_k + 2^{2k-2}\right) < 0$, then $q_{k-1}=0$ 
and so it will follow that $Q_{k-1}=Q_k$ and $R_{k-1}=R_k$. 

Summarizing, if we know $Q_k$, then we can deduce $q_{k-1}$ by

$$
q_{k-1} = 
\begin{cases}
0,  & \text{if} \quad R_k - \left(2^kQ_k + 2^{2k-2}\right) < 0 \\
1,  & \text{if} \quad R_k - \left(2^kQ_k + 2^{2k-2}\right) \ge 0
\end{cases}
$$

### Non-restoring Remainder
In practice, we need to compute the difference $R_k - \left(2^kQ_k + 2^{2k-2}\right)$,
and if the result is negative we have to restore it to the previous non-negative
remainder $R_k$. However, this requires an additional operation. 
We can circumvent this if we re-define the *Remainder* and allow the following remainders to take negative values as well.
In that case, we will perform an addition in the next calculation with the proper operand. Therefore, we will have $R_{k-1}$ be

$$R_{k-1} = R_k - \left(2^kQ_k + 2^{2k-2}\right)$$

whether it is negative or not. 

If $R_{k-1}\ge 0$, then $R_{k-2}$ will simply be

$$R_{k-2} = R_{k-1} - \left(2^{k-1}Q_{k-1} + 2^{2\left({k-1}\right)-2}\right)$$

However, if $R_{k-1} < 0$, then $R_{k-2}$ will be

$$R_{k-2} = R_{k-1} + \left(2^kQ_k + 2^{2k-2}\right) - \left(2^{k-1}Q_{k-1} + 2^{2\left({k-1}\right)-2}\right)$$

That is, we added back the term $\left(2^kQ_k + 2^{2k-2}\right)$ to get back the previous non-negative remainder $R_k$, and then subtracted the familiar $\left(2^{k-1}Q_{k-1} + 2^{2\left({k-1}\right)-2}\right)$ term. Since $R_{k-1} < 0$, then $Q_{k-1}=Q_k$, as we have established. Then, we can simplify the above equation as follows:

$$
\begin{aligned}
R_{k-2} &= R_{k-1} + \left(2^kQ_k + 2^{2k-2}\right) - \left(2^{k-1}Q_{k-1} + 2^{2\left({k-1}\right)-2}\right) \\
R_{k-2} &= R_{k-1} + \left(2^kQ_k - 2^{k-1}Q_{k-1}\right) + \left(2^{2k-2} - 2^{2\left({k-1}\right)-2}\right) \\
R_{k-2} &= R_{k-1} + \left(2^kQ_{k-1} - 2^{k-1}Q_{k-1}\right) + \left(2^2\times 2^{2\left({k-1}\right)-2} - 2^{2\left({k-1}\right)-2}\right) \\
R_{k-2} &= R_{k-1} + 2^{k-1}Q_{k-1} + 3\times 2^{2\left({k-1}\right)-2} \\
\end{aligned}
$$

Therefore, we can summarize that for any $k>0$, $R_{k-1}$ will be:

$$
R_{k-1} = 
\begin{cases}
R_{k} - \left(2^{k}Q_{k} + 2^{2{k}-2}\right),  & \text{if} \quad R_k \ge 0 \\
R_{k} + \left(2^{k}Q_{k} + 3\times 2^{2{k}-2}\right),  & \text{if} \quad R_k < 0 
\end{cases}
$$

We may now define the *Trial Divisor* $T_k$, for any $k>0$, as:

$$
T_{k} = 
\begin{cases}
2^{k}Q_{k} + 2^{2{k}-2},  & \text{if} \quad R_k \ge 0 \\
2^{k}Q_{k} + 3\times 2^{2{k}-2},  & \text{if} \quad R_k < 0 
\end{cases}
$$

and so

$$
R_{k-1} = 
\begin{cases}
R_{k} - T_k,  & \text{if} \quad R_k \ge 0 \\
R_{k} + T_k,  & \text{if} \quad R_k < 0 
\end{cases}
$$

Therefore, for the calculation of the next Remainder $R_{k-1}$ we perform a subtraction if $R_k\ge 0$ or an addition if $R_k < 0$, eliminating the need to restore with an extra operation. 

### Constructing the Trial Divisor $T_k$
The definition of $T_k$ itself appears to require an addition. However, $T_k$ can be constructed simply by its binary representation. Indeed, we have: 

$$T_k=2^{k}Q_{k} + r\times 2^{2{k}-2}$$

where $r=1$ if $R_k\ge 0$, and $r=3$ if $R_k < 0$. 
If we define the function $\text{sign}\left(i\right)$ as

$$
\text{sign}\left(i\right) = 
\begin{cases}
0,  & \text{if} \quad i \ge 0 \\
1,  & \text{if} \quad i < 0 
\end{cases}
$$

then the binary representation of $r$ is 

$$r=\text{sign}\left(R_k\right)\times 2^1 + 1\times 2^0 \qquad (4)$$

Therefore, using eqs. (2) and (4), the binary representation of $T_k$, for $k>0$, is:

$$
\begin{aligned}
T_k &= 2^{k}Q_{k} + r\times 2^{2k-2} \\
T_k &= 2^{k}\left(q_{n-1} 2^{n-1}+q_{n-2} 2^{n-2}+\dots+q_{k} 2^{k}\right) + \left(\text{sign}\left(R_k\right)\times 2^1 + 1\times 2^0\right)\times 2^{2k-2} \\
T_k &= q_{n-1} 2^{k+n-1}+q_{n-2} 2^{k+n-2}+\dots+q_{k} 2^{2k} + \text{sign}\left(R_k\right)\times 2^{2k-1} + 1\times 2^{2k-2} \\
T_k &= t_{k+n-1}2^{k+n-1}+t_{k+n-2}2^{k+n-2}+\dots+t_{2k}2^{2k}+t_{2k-1}2^{2k-1} + t_{2k-2}2^{2k-2} \qquad \left(5\right)
\end{aligned}
$$

For any $i$, $j$, and $N$ such that $0\le i\le j\le N$, 
for any number $A$ with a binary representation 

$$A=a_{N}2^N+a_{N-1}2^{N-1}+\dots+a_j2^j+\dots+a_i2^i+\dots+a_02^0$$

we define the vector $A[j:i]$ and component $A[i]$ as

$$
\begin{aligned}
A[j:i] &= [a_j, a_{j-1}, \dots, a_{i+1}, a_i] \\
A[i]   &= a_i
\end{aligned}
$$

So, from eq. (5) it follows that:

$$
\begin{alignedat}{1}
T_k[k+n-1:2k] &=Q_k[n-1:k] \\
T_k[2k-1] &=\text{sign}\left(R_k\right) \\
T_k[2k-2] &=1 
\end{alignedat}
$$

with the rest of the $t_m$'s for $m<2k-2$ and $m>k+n-1$ being $0$.

Therefore, $T_k$ can be constructed by direct bit value assignments 
from the bit values of $Q_k$ and $R_k$
without the need for extra operations. 

### Initial Step
We have, therefore, described an algorithm 
for computing the next best approximation $Q_{k-1}$ 
from the previous best approximation $Q_{k}$, for $k>0$. 
Therefore, by induction, we can eventually compute the required $Q_0$. 
The $n$-bit representation of $Q_0$ can be calculated in $n$ steps, 
starting from $k=n$ down to $k=1$, 
deducing the value of each $q_{k-1}$ as described, 
starting with an initial best approximation of $Q$ as $0$, i.e. $Q_{k=n}=0$ 
(giving $R_{k=n}=D$), which constitutes the initial induction step.

## VHDL algorithm
We apply the above algorithm in VHDL.  

We require a single arithmetic module, the CAS module, 
to perform the required operation,
either an addition or subtraction, controlled by the sign bit of the current 
stage's Remainder $R_k$. 

We use this CAS module in a Combinational Logic module that constructs
the Trial Divisor $T_k$ for the current stage and feeds it into the CAS module, 
along with the $R_k$ to perform the required addition/subtraction.

We wrap the Combinational Logic to a Stage module by adding Registers to the output
to save the computed $R_{k-1}$ and $Q_{k-1}$ values, which will be passed to the next stage.

We generate four stages, connecting them in a pipeline fashion, 
and wrap the whole thing to a top module, 
also adding Registers at the input for safety. 
