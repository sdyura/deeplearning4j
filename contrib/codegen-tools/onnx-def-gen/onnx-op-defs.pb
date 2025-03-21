
�
XYAbs"Abs*h
X-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Absolute takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the absolute is, y = abs(x), is applied to
the tensor elementwise.

�
inputoutputAcos"Acos*(
input-typesJfloatJfloat16Jdouble�2W
Calculates the arccosine (inverse of cosine) of the given input tensor, element-wise.

�
inputoutputAcosh"Acosh*(
input-typesJfloatJfloat16Jdouble�2M
Calculates the hyperbolic arccosine of the given input tensor element-wise.

�
R
T
inputsoutputsAdagrad"Adagrad*
decay_factor    �*
epsilon�7�5�*
norm_coefficient    �*
R-typesJfloatJdouble�*
T-typesJint64�* 
inputs-typesJfloatJdouble�2�
    Compute one iteration of ADAGRAD, a stochastic gradient based optimization
    algorithm. This operator can conduct the optimization of multiple tensor variables.

    Let's define the behavior of this operator. As you can imagine, ADAGRAD requires
    some parameters:

     - The initial learning-rate "R".
     - The update count "T". That is, the number of training iterations conducted.
     - A L2-norm regularization coefficient "norm_coefficient".
     - A learning-rate decay factor "decay_factor".
     - A small constant "epsilon" to avoid dividing-by-zero.

    At each ADAGRAD iteration, the optimized tensors are moved along a direction
    computed based on their estimated gradient and accumulated squared gradient. Assume
    that only a single tensor "X" is updated by this operator. We need the value of "X",
    its gradient "G", and its accumulated squared gradient "H". Therefore, variables in
    this operator's input list are sequentially "R", "T", "X", "G", and "H". Other
    parameters are given as attributes because they are usually constants. Also, the
    corresponding output tensors are the new value of "X" (called "X_new"), and then
    the new accumulated squared gradient (called "H_new"). Those outputs are computed
    from the given inputs following the pseudo code below.

    Let "+", "-", "*", and "/" are all element-wise arithmetic operations with
    numpy-style broadcasting support. The pseudo code to compute those outputs is:

      // Compute a scalar learning-rate factor. At the first update of X, T is generally
      // 0 (0-based update index) or 1 (1-based update index).
      r = R / (1 + T * decay_factor);

      // Add gradient of 0.5 * norm_coefficient * ||X||_2^2, where ||X||_2 is the 2-norm.
      G_regularized = norm_coefficient * X + G;

      // Compute new accumulated squared gradient.
      H_new = H + G_regularized * G_regularized;

      // Compute the adaptive part of per-coordinate learning rate. Note that Sqrt(...)
      // computes element-wise square-root.
      H_adaptive = Sqrt(H_new) + epsilon

      // Compute the new value of "X".
      X_new = X - r * G_regularized / H_adaptive;

    If one assign this operators to optimize multiple inputs, for example, "X_1" and "X_2", the same
    pseudo code may be extended to handle all tensors jointly. More specifically, we can view "X" as a
    concatenation of "X_1" and "X_2" (of course, their gradient and accumulate gradient should
    be concatenated too) and then just reuse the entire pseudo code.

    Note that ADAGRAD was first proposed in http://jmlr.org/papers/volume12/duchi11a/duchi11a.pdf.
    In that reference paper, this operator is a special case of the Figure 1's composite mirror
    descent update.

�
R
T
inputsoutputsAdam"Adam*
alphafff?�*
betaw�?�*
epsilon�7�5�*
norm_coefficient    �*
norm_coefficient_post    �*
R-typesJfloatJdouble�*
T-typesJint64�* 
inputs-typesJfloatJdouble�2�
    Compute one iteration of Adam, a stochastic gradient based optimization
    algorithm. This operator can conduct the optimization of multiple tensor variables.

    Let's define the behavior of this operator. First of all, Adam requires
    some parameters:

     - The learning-rate "R".
     - The update count "T". That is, the number of training iterations conducted.
     - A L2-norm regularization coefficient "norm_coefficient".
     - A small constant "epsilon" to avoid dividing-by-zero.
     - Two coefficients, "alpha" and "beta".

    At each Adam iteration, the optimized tensors are moved along a direction
    computed based on their exponentially-averaged historical gradient and
    exponentially-averaged historical squared gradient. Assume that only a tensor
    "X" is being optimized. The rest of required information is

     - the value of "X",
     - "X"'s gradient (denoted by "G"),
     - "X"'s exponentially-averaged historical gradient (denoted by "V"), and
     - "X"'s exponentially-averaged historical squared gradient (denoted by "H").

    Some of those parameters are passed into this operator as input tensors and others
    are stored as this operator's attributes. Specifically, this operator's input tensor
    list is ["R", "T", "X", "G", "V", "H"]. That is, "R" is the first input, "T" is
    the second input, and so on. Other parameters are given as attributes because they
    are constants. Moreover, the corresponding output tensors are

     - the new value of "X" (called "X_new"),
     - the new exponentially-averaged historical gradient (denoted by "V_new"), and
     - the new exponentially-averaged historical squared gradient (denoted by "H_new").

    Those outputs are computed following the pseudo code below.

    Let "+", "-", "*", and "/" are all element-wise arithmetic operations with
    numpy-style broadcasting support. The pseudo code to compute those outputs is:

      // Add gradient of 0.5 * norm_coefficient * ||X||_2^2, where ||X||_2 is the 2-norm.
      G_regularized = norm_coefficient * X + G

      // Update exponentially-averaged historical gradient.
      V_new = alpha * V + (1 - alpha) * G_regularized

      // Update exponentially-averaged historical squared gradient.
      H_new = beta * H + (1 - beta) * G_regularized * G_regularized

      // Compute the element-wise square-root of H_new. V_new will be element-wisely
      // divided by H_sqrt for a better update direction.
      H_sqrt = Sqrt(H_new) + epsilon

      // Compute learning-rate. Note that "alpha**T"/"beta**T" is alpha's/beta's T-th power.
      R_adjusted = T > 0 ? R * Sqrt(1 - beta**T) / (1 - alpha**T) : R

      // Compute new value of "X".
      X_new = X - R_adjusted * V_new / H_sqrt

      // Post-update regularization.
      X_final = (1 - norm_coefficient_post) * X_new

    If there are multiple inputs to be optimized, the pseudo code will be applied
    independently to each of them.

�
A
BCAdd"Add*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Performs element-wise binary addition (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

(Opset 14 change): Extend supported types to include uint8, int8, uint16, and int16.

�
A
BCAnd"And*
A-typesJbool�*
B-typesJbool�2�
Returns the tensor resulted from performing the `and` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
datareducedArgMax"ArgMax*
axis �*
keepdims�*
select_last_index �*k

data-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Computes the indices of the max elements of the input tensor's element along the
provided axis. The resulting tensor has the same rank as the input if keepdims equal 1.
If keepdims equal 0, then the resulting tensor have the reduced dimension pruned.
If select_last_index is True (default False), the index of the last occurrence of the max
is selected if the max appears more than once in the input. Otherwise the index of the
first occurrence is selected.
The type of the output tensor is integer.
�
datareducedArgMin"ArgMin*
axis �*
keepdims�*
select_last_index �*k

data-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Computes the indices of the min elements of the input tensor's element along the
provided axis. The resulting tensor has the same rank as the input if keepdims equal 1.
If keepdims equal 0, then the resulting tensor have the reduced dimension pruned.
If select_last_index is True (default False), the index of the last occurrence of the min
is selected if the min appears more than once in the input. Otherwise the index of the
first occurrence is selected.
The type of the output tensor is integer.
�
X
YZArrayFeatureExtractor"ArrayFeatureExtractor*1
X-typesJint32JdoubleJfloatJint64Jstring�*
Y-typesJint64�2�
    Select elements of the input tensor based on the indices passed.<br>
    The indices are applied to the last axes of the tensor.

�
inputoutputAsin"Asin*(
input-typesJfloatJfloat16Jdouble�2S
Calculates the arcsine (inverse of sine) of the given input tensor, element-wise.

�
inputoutputAsinh"Asinh*(
input-typesJfloatJfloat16Jdouble�2K
Calculates the hyperbolic arcsine of the given input tensor element-wise.

�
inputoutputAtan"Atan*(
input-typesJfloatJfloat16Jdouble�2Y
Calculates the arctangent (inverse of tangent) of the given input tensor, element-wise.

�
inputoutputAtanh"Atanh*(
input-typesJfloatJfloat16Jdouble�2N
Calculates the hyperbolic arctangent of the given input tensor element-wise.

�
XYAveragePool"AveragePool*
auto_pad"NOTSET�*
	ceil_mode �*
count_include_pad �*
kernel_shape" �*
pads" �*
strides" �*$
X-typesJfloatJfloat16Jdouble�2�
 AveragePool consumes an input tensor X and applies average pooling across
 the tensor according to kernel sizes, stride sizes, and pad lengths.
 average pooling consisting of computing the average on all values of a
 subset of the input tensor according to the kernel size and downsampling the
 data into the output tensor Y for further processing. The output spatial shape will be following:
 ```
 output_spatial_shape[i] = floor((input_spatial_shape[i] + pad_shape[i] - kernel_spatial_shape[i]) / strides_spatial_shape[i] + 1)
 ```
 or
 ```
 output_spatial_shape[i] = ceil((input_spatial_shape[i] + pad_shape[i] - kernel_spatial_shape[i]) / strides_spatial_shape[i] + 1)
 ```
 if ceil_mode is enabled

 ```
 * pad_shape[i] is sum of pads along axis i
 ```

 `auto_pad` is a DEPRECATED attribute. If you are using them currently, the output spatial shape will be following:
 ```
 VALID: output_spatial_shape[i] = ceil((input_spatial_shape[i] - kernel_spatial_shape[i] + 1) / strides_spatial_shape[i])
 SAME_UPPER or SAME_LOWER: output_spatial_shape[i] = ceil(input_spatial_shape[i] / strides_spatial_shape[i])
 ```
 And pad shape will be following if `SAME_UPPER` or `SAME_LOWER`:
 ```
 pad_shape[i] = (output_spatial_shape[i] - 1) * strides_spatial_shape[i] + kernel_spatial_shape[i] - input_spatial_shape[i]
 ```
 The output of each pooling window is divided by the number of elements (exclude pad when attribute count_include_pad is zero).
 
�
X
scale
B

input_mean
	input_varYrunning_meanrunning_varBatchNormalization"BatchNormalization*
epsilon��'7�*
momentumfff?�*
training_mode �*.
X-typesJfloatJfloat16Jbfloat16Jdouble�*2
scale-typesJfloatJfloat16Jbfloat16Jdouble�*.
B-typesJfloatJfloat16Jbfloat16Jdouble�*7
input_mean-typesJfloatJfloat16Jbfloat16Jdouble�*6
input_var-typesJfloatJfloat16Jbfloat16Jdouble�2�
Carries out batch normalization as described in the paper
https://arxiv.org/abs/1502.03167. Depending on the mode it is being run,
There are five required inputs 'X', 'scale', 'B', 'input_mean' and
'input_var'.
Note that 'input_mean' and 'input_var' are expected to be the estimated
statistics in inference mode (training_mode=False, default),
and the running statistics in training mode (training_mode=True).
There are multiple cases for the number of outputs, which we list below:

Output case #1: Y, running_mean, running_var (training_mode=True)
Output case #2: Y (training_mode=False)

When training_mode=False, extra outputs are invalid.
The outputs are updated as follows when training_mode=True:
```
running_mean = input_mean * momentum + current_mean * (1 - momentum)
running_var = input_var * momentum + current_var * (1 - momentum)

Y = (X - current_mean) / sqrt(current_var + epsilon) * scale + B

where:

current_mean = ReduceMean(X, axis=all_except_channel_index)
current_var =  ReduceVar(X, axis=all_except_channel_index)

Notice that ReduceVar refers to the population variance, and it equals to
sum(sqrd(x_i - x_avg)) / N
where N is the population size (this formula does not use sample size N - 1).

```

When training_mode=False:
```
Y = (X - input_mean) / sqrt(input_var + epsilon) * scale + B
```

For previous (depreciated) non-spatial cases, implementors are suggested
to flatten the input shape to (N x C * D1 * D2 * ... * Dn) before a BatchNormalization Op.
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�
XY	Binarizer"	Binarizer*
	threshold    �*)
X-typesJint32Jint64JfloatJdouble�2�
    Maps the values of the input tensor to either 0 or 1, element-wise, based on the outcome of a comparison against a threshold value.

�
X
YZBitShift"BitShift*
	direction" �*+
X-typesJuint8Juint32Juint64Juint16�*+
Y-typesJuint8Juint32Juint64Juint16�2�
Bitwise shift operator performs element-wise operation. For each input element, if the
 attribute "direction" is "RIGHT", this operator moves its binary representation toward
 the right side so that the input value is effectively decreased. If the attribute "direction"
 is "LEFT", bits of binary representation moves toward the left side, which results the
 increase of its actual value. The input X is the tensor to be shifted and another input
 Y specifies the amounts of shifting. For example, if "direction" is "Right", X is [1, 4],
 and S is [1, 1], the corresponding output Z would be [0, 2]. If "direction" is "LEFT" with
 X=[1, 2] and S=[1, 2], the corresponding output Y would be [2, 8].

 Because this operator supports Numpy-style broadcasting, X's and Y's shapes are
 not necessarily identical.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).
�
inputoutputCast"Cast*	
to" �*z
input-typesJbfloat16Jint16Jint8Juint16Juint64Jint32JboolJdoubleJfloat16Juint8JfloatJint64Juint32Jstring�2�
The operator casts the elements of a given input tensor to a data type
specified by the 'to' argument and returns an output tensor of the same size in
the converted type. The 'to' argument must be one of the data types specified
in the 'DataType' enum field in the TensorProto message.

Casting from string tensor in plain (e.g., "3.14" and "1000") and scientific numeric representations
(e.g., "1e-5" and "1E8") to float types is supported. For example, converting string "100.5" to an integer may
result 100. There are some string literals reserved for special floating-point values;
"+INF" (and "INF"), "-INF", and "NaN" are positive infinity, negative infinity, and not-a-number, respectively.
Any string which can exactly match "+INF" in a case-insensitive way would be mapped to positive infinite. Similarly,
this case-insensitive rule is applied to "INF" and "NaN". When casting from numeric tensors
to string tensors, plain floating-point representation (such as "314.15926") would be used.
Converting non-numerical-literal string such as "Hello World!" is an undefined behavior. Cases
of converting string representing floating-point arithmetic value, such as "2.718", to INT is an undefined behavior.

Conversion from a numerical type to any numerical type is always allowed.
User must be aware of precision loss and value change caused by range difference between two types.
For example, a 64-bit float 3.1415926459 may be round to a 32-bit float 3.141592. Similarly, converting
an integer 36 to Boolean may produce 1 because we truncate bits which can't be stored in the targeted type.

�
XYCastMap"CastMap*
cast_to"TO_FLOAT�*
map_form"DENSE�*
max_map�*/
X-typesJmap(int64,stringJmap(int64,float�2�
    Converts a map to a tensor.<br>The map key must be an int64 and the values will be ordered
    in ascending order based on this key.<br>The operator supports dense packing or sparse packing.
    If using sparse packing, the key cannot exceed the max_map-1 value.

�
XYCategoryMapper"CategoryMapper*
cats_int64s" �*
cats_strings" �*
default_int64����������*
default_string"_Unused�*
X-typesJint64Jstring�2�
    Converts strings to integers and vice versa.<br>
    Two sequences of equal length are used to map between integers and strings,
    with strings and integers at the same index detailing the mapping.<br>
    Each operator converts either integers to strings or strings to integers, depending
    on which default value attribute is provided. Only one default value attribute
    should be defined.<br>
    If the string default value is set, it will convert integers to strings.
    If the int default value is set, it will convert strings to integers.

�
XYCeil"Ceil*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Ceil takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the ceil is, y = ceil(x), is applied to
the tensor elementwise.

�
XYCelu"Celu*
alpha  �?�*
X-typesJfloat�2�
Continuously Differentiable Exponential Linear Units:
Perform the linear unit element-wise on the input tensor X
using formula:

```
max(0,x) + min(0,alpha*(exp(x/alpha)-1))
```

�
input
min
maxoutputClip"Clip*l
input-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*j
	min-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*j
	max-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Clip operator limits the given input within an interval. The interval is
specified by the inputs 'min' and 'max'. They default to
numeric_limits::lowest() and numeric_limits::max(), respectively.

�
input
	conditionoutputCompress"Compress*
axis" �*�
input-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
condition-typesJbool�2�
    Selects slices from an input tensor along a given axis where condition evaluates to True for each axis index.
    In case axis is not provided, input is flattened before elements are selected.
    Compress behaves like numpy.compress: https://docs.scipy.org/doc/numpy/reference/generated/numpy.compress.html
    
�
inputsconcat_resultConcat"Concat*
axis" �*�
inputs-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�Concatenate a list of tensors into a single tensor. All input tensors must have the same shape, except for the dimension size of the axis to concatenate on.
�
input_sequenceconcat_resultConcatFromSequence"ConcatFromSequence*
axis" �*
new_axis �*�
input_sequence-typesJ
seq(uint32J
seq(stringJseq(boolJseq(int8Jseq(float16J	seq(uint8J	seq(floatJ	seq(int64J
seq(uint64Jseq(complex64J
seq(doubleJ	seq(int32J
seq(uint16Jseq(complex128J	seq(int16�2�
Concatenate a sequence of tensors into a single tensor.
All input tensors must have the same shape, except for the dimension size of the axis to concatenate on.
By default 'new_axis' is 0, the behavior is similar to numpy.concatenate.
When 'new_axis' is 1, the behavior is similar to numpy.stack.

�outputConstant"Constant*
sparse_value" �*
value" �*
value_float" �*
value_floats" �*
	value_int" �*

value_ints" �*
value_string" �*
value_strings" �2�
This operator produces a constant tensor. Exactly one of the provided attributes, either value, sparse_value,
or value_* must be specified.

�
inputoutputConstantOfShape"ConstantOfShape*
value" �*
input-typesJint64�2/
Generate a tensor with given value and shape.

�
X
W
BYConv"Conv*
auto_pad"NOTSET�*
	dilations" �*
group�*
kernel_shape" �*
pads" �*
strides" �*$
X-typesJfloatJfloat16Jdouble�*$
W-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�2Y
The convolution operator consumes an input tensor and a filter, and
computes the output.
�
x
w
x_zero_point
w_zero_pointyConvInteger"ConvInteger*
auto_pad"NOTSET�*
	dilations" �*
group�*
kernel_shape" �*
pads" �*
strides" �*
x-typesJuint8Jint8�*
w-typesJuint8Jint8�*$
x_zero_point-typesJuint8Jint8�*$
w_zero_point-typesJuint8Jint8�2�
The integer convolution operator consumes an input tensor, its zero-point, a filter, and its zero-point,
and computes the output. The production MUST never overflow. The accumulation may overflow if and only if in 32 bits.

�
X
W
BYConvTranspose"ConvTranspose*
auto_pad"NOTSET�*
	dilations" �*
group�*
kernel_shape" �*
output_padding" �*
output_shape" �*
pads" �*
strides" �*$
X-typesJfloatJfloat16Jdouble�*$
W-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�2�
The convolution transpose operator consumes an input tensor and a filter,
and computes the output.

If the pads parameter is provided the shape of the output is calculated via the following equation:

  output_shape[i] = stride[i] * (input_size[i] - 1) + output_padding[i] + ((kernel_shape[i] - 1) * dilations[i] + 1) - pads[start_i] - pads[end_i]

output_shape can also be explicitly specified in which case pads values are auto generated using these equations:

  total_padding[i] = stride[i] * (input_size[i] - 1) + output_padding[i] + ((kernel_shape[i] - 1) * dilations[i] + 1) - output_shape[i]
  If (auto_pads != SAME_UPPER): pads[start_i] = total_padding[i]/2; pads[end_i] = total_padding[i] - (total_padding[i]/2)
  Else: pads[start_i] = total_padding[i] - (total_padding[i]/2); pads[end_i] = (total_padding[i]/2).

    
�
inputoutputCos"Cos*(
input-typesJfloatJfloat16Jdouble�2@
Calculates the cosine of the given input tensor, element-wise.

�
inputoutputCosh"Cosh*(
input-typesJfloatJfloat16Jdouble�2J
Calculates the hyperbolic cosine of the given input tensor element-wise.

�
x
axisyCumSum"CumSum*
	exclusive �*
reverse �*L
x-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�*

axis-typesJint32Jint64�2�
Performs cumulative sum of the input elements along the given axis.
By default, it will do the sum inclusively meaning the first element is copied as is.
Through an `exclusive` attribute, this behavior can change to exclude the first element.
It can also perform summation in the opposite direction of the axis. For that, set `reverse` attribute to 1.

Example:
```
input_x = [1, 2, 3]
axis=0
output = [1, 3, 6]
exclusive=1
output = [0, 1, 3]
exclusive=0
reverse=1
output = [6, 5, 3]
exclusive=1
reverse=1
output = [5, 3, 0]
```
 
�

inputoutputDepthToSpace"DepthToSpace*
	blocksize" �*
mode"DCR�*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�	DepthToSpace rearranges (permutes) data from depth into blocks of spatial data.
This is the reverse transformation of SpaceToDepth. More specifically, this op outputs a copy of
the input tensor where values from the depth dimension are moved in spatial blocks to the height
and width dimensions. By default, `mode` = `DCR`.
In the DCR mode, elements along the depth dimension from the input tensor are rearranged in the
following order: depth, column, and then row. The output y is computed from the input x as below:

b, c, h, w = x.shape

tmp = np.reshape(x, [b, blocksize, blocksize, c // (blocksize**2), h, w])

tmp = np.transpose(tmp, [0, 3, 4, 1, 5, 2])

y = np.reshape(tmp, [b, c // (blocksize**2), h * blocksize, w * blocksize])


In the CRD mode, elements along the depth dimension from the input tensor are rearranged in the
following order: column, row, and the depth. The output y is computed from the input x as below:

b, c, h, w = x.shape

tmp = np.reshape(x, [b, c // (blocksize ** 2), blocksize, blocksize, h, w])

tmp = np.transpose(tmp, [0, 1, 4, 2, 5, 3])

y = np.reshape(tmp, [b, c // (blocksize ** 2), h * blocksize, w * blocksize])


�
x
x_scale
x_zero_pointyDequantizeLinear"DequantizeLinear*
axis�* 
x-typesJuint8Jint32Jint8�*
x_scale-typesJfloat�*+
x_zero_point-typesJuint8Jint32Jint8�2�
The linear dequantization operator. It consumes a quantized tensor, a scale, and a zero point to compute the full precision tensor.
The dequantization formula is y = (x - x_zero_point) * x_scale. 'x_scale' and 'x_zero_point' must have same shape, and can be either a scalar
for per-tensor / per layer quantization, or a 1-D tensor for per-axis quantizations.
'x_zero_point' and 'x' must have same type. 'x' and 'y' must have same shape. In the case of dequantizing int32,
there's no zero point (zero point is supposed to be 0).

�
XYDet"Det*$
X-typesJfloatJfloat16Jdouble�2�
Det calculates determinant of a square matrix or batches of square matrices.
Det takes one input tensor of shape `[*, M, M]`, where `*` is zero or more batch dimensions,
and the inner-most 2 dimensions form square matrices.
The output is a tensor of shape `[*]`, containing the determinants of all input submatrices.
e.g., When the input is 2-D, the output is a scalar(shape is empty: `[]`).

�	
XYDictVectorizer"DictVectorizer*
int64_vocabulary" �*
string_vocabulary" �*x
X-typesJmap(string,doubleJmap(int64,stringJmap(string,int64Jmap(int64,floatJmap(int64,doubleJmap(string,float�2�
    Uses an index mapping to convert a dictionary to an array.<br>
    Given a dictionary, each key is looked up in the vocabulary attribute corresponding to
    the key type. The index into the vocabulary array at which the key is found is then
    used to index the output 1-D tensor 'Y' and insert into it the value found in the dictionary 'X'.<br>
    The key type of the input map must correspond to the element type of the defined vocabulary attribute.
    Therefore, the output array will be equal in length to the index mapping vector parameter.
    All keys in the input dictionary must be present in the index mapping vector.
    For each item in the input dictionary, insert its value in the output array.
    Any keys not present in the input dictionary, will be zero in the output array.<br>
    For example: if the ``string_vocabulary`` parameter is set to ``["a", "c", "b", "z"]``,
    then an input of ``{"a": 4, "c": 8}`` will produce an output of ``[4, 8, 0, 0]``.
    
�
A
BCDiv"Div*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Performs element-wise binary division (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

(Opset 14 change): Extend supported types to include uint8, int8, uint16, and int16.

�
data
ratio
training_modeoutputmaskDropout"Dropout*
seed" �*1

data-typesJfloatJfloat16Jbfloat16Jdouble�*(
ratio-typesJfloatJfloat16Jdouble�*
training_mode-typesJbool�2�
Dropout takes an input floating-point tensor, an optional input ratio (floating-point scalar) and an optional input training_mode (boolean scalar). It produces two tensor outputs,
output (floating-point tensor) and mask (optional `Tensor<bool>`). If `training_mode` is true then the output Y will be a random dropout;
Note that this Dropout scales the masked input data by the following equation, so to convert the trained model into inference mode,
the user can simply not pass `training_mode` input or set it to false.
```
output = scale * data * mask,
```
where
```
scale = 1. / (1. - ratio).
```
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�
xyy_scaley_zero_pointDynamicQuantizeLinear"DynamicQuantizeLinear*
x-typesJfloat�2�
A Function to fuse calculation for Scale, Zero Point and FP32->8Bit convertion of FP32 Input data.
Outputs Scale, ZeroPoint and Quantized Input for a given FP32 Input.
Scale is calculated as:
```
 y_scale = (max(x) - min(x))/(qmax - qmin)
 * where qmax and qmin are max and min values for quantization range .i.e [0, 255] in case of uint8
 * data range is adjusted to include 0.
```
Zero point is calculated as:
```
intermediate_zero_point = qmin - min(x)/y_scale
y_zero_point = cast(round(saturate(itermediate_zero_point)))
* where qmax and qmin are max and min values for quantization range .i.e [0, 255] in case of uint8
* for saturation, it saturates to [0, 255] if it's uint8, or [-127, 127] if it's int8. Right now only uint8 is supported.
* rounding to nearest ties to even.
```
Data quantization formula is:
```
y = saturate (round (x / y_scale) + y_zero_point)
* for saturation, it saturates to [0, 255] if it's uint8, or [-127, 127] if it's int8. Right now only uint8 is supported.
* rounding to nearest ties to even.
```

�
InputsOutputEinsum"Einsum*
equation" �*c
Inputs-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
An einsum of the form ```term1, term2 -> output-term``` produces an output tensor using the following equation

```output[output-term] = reduce-sum( input1[term1] * input2[term] )```

where the reduce-sum performs a summation over all the indices occurring in the input terms (term1, term2)
that do not occur in the output-term.

The Einsum operator evaluates algebraic tensor operations on a sequence of tensors, using the Einstein summation
convention. The equation string contains a comma-separated sequence of lower case letters. Each term corresponds to
an operand tensor, and the characters within the terms correspond to operands dimensions.

This sequence may be followed by "->" to separate the left and right hand side of the equation.
If the equation contains "->" followed by the right-hand side, the explicit (not classical) form of the Einstein
summation is performed, and the right-hand side indices indicate output tensor dimensions. In other cases,
output indices are (implicitly) set to the alphabetically sorted sequence of indices appearing exactly once in the
equation.

When a dimension character is repeated in the left-hand side, it represents summation along the dimension.

The equation may contain ellipsis ("...") to enable broadcasting. Ellipsis must indicate a fixed number of dimensions.
Specifically, every occurrence of ellipsis in the equation must represent the same number of dimensions.
The right-hand side may contain exactly one ellipsis. In implicit mode, the ellipsis dimensions are set to the
beginning of the output. The equation string may contain space (U+0020) character.

�
XYElu"Elu*
alpha  �?�*$
X-typesJfloatJfloat16Jdouble�2�
Elu takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the function `f(x) = alpha * (exp(x) - 1.) for x <
0`, `f(x) = x for x >= 0`., is applied to the tensor elementwise.


�
A
BCEqual"Equal*n
A-typesJbfloat16JboolJuint16Jint16Jint8Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*n
B-typesJbfloat16JboolJuint16Jint16Jint8Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Returns the tensor resulted from performing the `equal` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
inputoutputErf"Erf*l
input-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2E
Computes the error function of the given input tensor element-wise.

�
inputoutputExp"Exp*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2E
Calculates the exponential of the given input tensor, element-wise.

�
input
shapeoutputExpand"Expand*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
shape-typesJint64�2�
Broadcast the input tensor following the given shape and the broadcast rule.
The broadcast rule is similar to numpy.array(input) * numpy.ones(shape):
Dimensions are right alignment;
Two corresponding dimension must have the same value, or one of them is equal to 1.
Also, this operator is similar to numpy.broadcast_to(input, shape),
but the major difference is numpy.broadcast_to() does not allow shape to be smaller than input.size().
It is possible that the output.shape is not equal to shape, when some dimensions in shape is equal to 1,
or the shape.ndim < input.shape.ndim.

�
inputoutputEyeLike"EyeLike*
dtype" �*
k �*h
input-typesJint16Jint8Juint16Juint64Jint32JboolJdoubleJfloat16Juint8JfloatJint64Juint32�2�
Generate a 2D tensor (matrix) with ones on the diagonal and zeros everywhere else. Only 2D
tensors are supported, i.e. input T1 must be of rank 2. The shape of the output tensor is the
same as the input tensor. The data type can be specified by the 'dtype' argument. If
'dtype' is not specified, then the type of input tensor is used. By default, the main diagonal
is populated with ones, but attribute 'k' can be used to populate upper or lower diagonals.
The 'dtype' argument must be one of the data types specified in the 'DataType' enum field in the
TensorProto message and be valid as an output type.

�
XYFeatureVectorizer"FeatureVectorizer*
inputdimensions" �*)
X-typesJfloatJint64JdoubleJint32�2�
    Concatenates input tensors into one continuous output.<br>
    All input shapes are 2-D and are concatenated along the second dimention. 1-D tensors are treated as [1,C].
    Inputs are copied to the output maintaining the order of the input arguments.<br>
    All inputs must be integers or floats, while the output will be all floating point values.

�
inputoutputFlatten"Flatten*
axis�*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Flattens the input tensor into a 2D matrix. If input tensor has shape
(d_0, d_1, ... d_n) then the output will have shape
(d_0 X d_1 ... d_(axis-1), d_axis X d_(axis+1) ... X dn).

�
XYFloor"Floor*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Floor takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the floor is, y = floor(x), is applied to
the tensor elementwise.

�
X
W
R
B
sequence_lens
	initial_hYY_hGRU"GRU*
activation_alpha" �*
activation_beta" �*
activations" �*
clip" �*
	direction"forward�*
hidden_size" �*
layout �*
linear_before_reset �*$
X-typesJfloatJfloat16Jdouble�*$
W-typesJfloatJfloat16Jdouble�*$
R-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�*
sequence_lens-typesJint32�*,
initial_h-typesJfloatJfloat16Jdouble�2�
Computes an one-layer GRU. This operator is usually supported via some custom
implementation such as CuDNN.

Notations:

`X` - input tensor

`z` - update gate

`r` - reset gate

`h` - hidden gate

`t` - time step (t-1 means previous time step)

`W[zrh]` - W parameter weight matrix for update, reset, and hidden gates

`R[zrh]` - R recurrence weight matrix for update, reset, and hidden gates

`Wb[zrh]` - W bias vectors for update, reset, and hidden gates

`Rb[zrh]` - R bias vectors for update, reset, and hidden gates

`WB[zrh]` - W parameter weight matrix for backward update, reset, and hidden gates

`RB[zrh]` - R recurrence weight matrix for backward update, reset, and hidden gates

`WBb[zrh]` - W bias vectors for backward update, reset, and hidden gates

`RBb[zrh]` - R bias vectors for backward update, reset, and hidden gates

`H` - Hidden state

`num_directions` - 2 if direction == bidirectional else 1

Activation functions:

  Relu(x)                - max(0, x)

  Tanh(x)                - (1 - e^{-2x})/(1 + e^{-2x})

  Sigmoid(x)             - 1/(1 + e^{-x})

  (NOTE: Below are optional)

  Affine(x)              - alpha*x + beta

  LeakyRelu(x)           - x if x >= 0 else alpha * x

  ThresholdedRelu(x)     - x if x >= alpha else 0

  ScaledTanh(x)          - alpha*Tanh(beta*x)

  HardSigmoid(x)         - min(max(alpha*x + beta, 0), 1)

  Elu(x)                 - x if x >= 0 else alpha*(e^x - 1)

  Softsign(x)            - x/(1 + |x|)

  Softplus(x)            - log(1 + e^x)

Equations (Default: f=Sigmoid, g=Tanh):

  - zt = f(Xt*(Wz^T) + Ht-1*(Rz^T) + Wbz + Rbz)

  - rt = f(Xt*(Wr^T) + Ht-1*(Rr^T) + Wbr + Rbr)

  - ht = g(Xt*(Wh^T) + (rt (.) Ht-1)*(Rh^T) + Rbh + Wbh) # default, when linear_before_reset = 0

  - ht = g(Xt*(Wh^T) + (rt (.) (Ht-1*(Rh^T) + Rbh)) + Wbh) # when linear_before_reset != 0

  - Ht = (1 - zt) (.) ht + zt (.) Ht-1
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�	
data
indicesoutputGather"Gather*
axis �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�* 
indices-typesJint32Jint64�2�
Given `data` tensor of rank r >= 1, and `indices` tensor of rank q, gather
entries of the axis dimension of `data` (by default outer-most one as axis=0) indexed by `indices`, and concatenates
them in an output tensor of rank q + (r - 1).

axis = 0 :

Let
k = indices[i_{0}, ..., i_{q-1}]
Then
output[i_{0}, ..., i_{q-1}, j_{0}, ..., j_{r-2}] = input[k , j_{0}, ..., j_{r-2}]

```
  data = [
      [1.0, 1.2],
      [2.3, 3.4],
      [4.5, 5.7],
  ]
  indices = [
      [0, 1],
      [1, 2],
  ]
  output = [
      [
          [1.0, 1.2],
          [2.3, 3.4],
      ],
      [
          [2.3, 3.4],
          [4.5, 5.7],
      ],
  ]
```
axis = 1 :

Let
k = indices[i_{0}, ..., i_{q-1}]
Then
output[i_{0}, ..., i_{q-1}, j_{0}, ..., j_{r-2}] = input[j_{0}, k, j_{1}, ..., j_{r-2}]

```
  data = [
      [1.0, 1.2, 1.9],
      [2.3, 3.4, 3.9],
      [4.5, 5.7, 5.9],
  ]
  indices = [
      [0, 2],
  ]
  axis = 1,
  output = [
          [[1.0, 1.9]],
          [[2.3, 3.9]],
          [[4.5, 5.9]],
  ]
```

�
data
indicesoutputGatherElements"GatherElements*
axis �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�* 
indices-typesJint32Jint64�2�


GatherElements takes two inputs `data` and `indices` of the same rank r >= 1
and an optional attribute `axis` that identifies an axis of `data`
(by default, the outer-most axis, that is axis 0). It is an indexing operation
that produces its output by indexing into the input data tensor at index
positions determined by elements of the `indices` tensor.
Its output shape is the same as the shape of `indices` and consists of one value
(gathered from the `data`) for each element in `indices`.

For instance, in the 3-D case (r = 3), the output produced is determined
by the following equations:
```
  out[i][j][k] = input[index[i][j][k]][j][k] if axis = 0,
  out[i][j][k] = input[i][index[i][j][k]][k] if axis = 1,
  out[i][j][k] = input[i][j][index[i][j][k]] if axis = 2,
```

This operator is also the inverse of ScatterElements. It is similar to Torch's gather operation.

Example 1:
```
  data = [
      [1, 2],
      [3, 4],
  ]
  indices = [
      [0, 0],
      [1, 0],
  ]
  axis = 1
  output = [
      [
        [1, 1],
        [4, 3],
      ],
  ]
```
Example 2:
```
  data = [
      [1, 2, 3],
      [4, 5, 6],
      [7, 8, 9],
  ]
  indices = [
      [1, 2, 0],
      [2, 0, 0],
  ]
  axis = 0
  output = [
      [
        [4, 8, 3],
        [7, 2, 3],
      ],
  ]
```

�
data
indicesoutputGatherND"GatherND*

batch_dims �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
indices-typesJint64�2�
Given `data` tensor of rank `r` >= 1, `indices` tensor of rank `q` >= 1, and `batch_dims` integer `b`, this operator gathers
slices of `data` into an output tensor of rank `q + r - indices_shape[-1] - 1 - b`.

`indices` is an q-dimensional integer tensor, best thought of as a `(q-1)`-dimensional tensor of index-tuples into `data`,
where each element defines a slice of `data`

`batch_dims` (denoted as `b`) is an integer indicating the number of batch dimensions, i.e the leading `b` number of dimensions of
`data` tensor and `indices` are representing the batches, and the gather starts from the `b+1` dimension.

Some salient points about the inputs' rank and shape:

1) r >= 1 and q >= 1 are to be honored. There is no dependency condition to be met between ranks `r` and `q`

2) The first `b` dimensions of the shape of `indices` tensor and `data` tensor must be equal.

3) b < min(q, r) is to be honored.

4) The `indices_shape[-1]` should have a value between 1 (inclusive) and rank `r-b` (inclusive)

5) All values in `indices` are expected to be within bounds [-s, s-1] along axis of size `s` (i.e.) `-data_shape[i] <= indices[...,i] <= data_shape[i] - 1`.
   It is an error if any of the index values are out of bounds.

The output is computed as follows:

The output tensor is obtained by mapping each index-tuple in the `indices` tensor to the corresponding slice of the input `data`.

1) If `indices_shape[-1] > r-b` => error condition

2) If `indices_shape[-1] == r-b`, since the rank of `indices` is `q`, `indices` can be thought of as `N` `(q-b-1)`-dimensional tensors
   containing 1-D tensors of dimension `r-b`, where `N` is an integer equals to the product of 1 and all the elements in the batch dimensions
   of the indices_shape. Let us think of each such `r-b` ranked tensor as `indices_slice`. Each *scalar value* corresponding to `data[0:b-1,indices_slice]`
   is filled into the corresponding location of the `(q-b-1)`-dimensional tensor to form the `output` tensor (Example 1 below)

3) If `indices_shape[-1] < r-b`, since the rank of `indices` is `q`, `indices` can be thought of as `N` `(q-b-1)`-dimensional tensor
   containing 1-D tensors of dimension `< r-b`. Let us think of each such tensors as `indices_slice`. Each *tensor slice* corresponding
   to `data[0:b-1, indices_slice , :]` is filled into the corresponding location of the `(q-b-1)`-dimensional tensor
   to form the `output` tensor (Examples 2, 3, 4 and 5 below)

This operator is the inverse of `ScatterND`.

`Example 1`

  batch_dims = 0

  data    = [[0,1],[2,3]]   # data_shape = [2, 2]

  indices = [[0,0],[1,1]]   # indices_shape = [2, 2]

  output  = [0,3]           # output_shape = [2]

`Example 2`

  batch_dims = 0

  data    = [[0,1],[2,3]]  # data_shape = [2, 2]

  indices = [[1],[0]]      # indices_shape = [2, 1]

  output  = [[2,3],[0,1]]  # output_shape = [2, 2]

`Example 3`

  batch_dims = 0

  data    = [[[0,1],[2,3]],[[4,5],[6,7]]] # data_shape = [2, 2, 2]

  indices = [[0,1],[1,0]]                 # indices_shape = [2, 2]

  output  = [[2,3],[4,5]]                 # output_shape = [2, 2]

`Example 4`

  batch_dims = 0

  data    = [[[0,1],[2,3]],[[4,5],[6,7]]] # data_shape = [2, 2, 2]

  indices = [[[0,1]],[[1,0]]]             # indices_shape = [2, 1, 2]

  output  = [[[2,3]],[[4,5]]]             # output_shape = [2, 1, 2]

`Example 5`

  batch_dims = 1

  data    = [[[0,1],[2,3]],[[4,5],[6,7]]] # data_shape = [2, 2, 2]

  indices = [[1],[0]]             # indices_shape = [2, 1]

  output  = [[2,3],[4,5]]             # output_shape = [2, 2]



�

A
B
CYGemm"Gemm*
alpha  �?�*
beta  �?�*
transA �*
transB �*L
A-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�*L
B-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�*L
C-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�General Matrix multiplication:
https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms#Level_3

A' = transpose(A) if transA else A

B' = transpose(B) if transB else B

Compute Y = alpha * A' * B' + beta * C, where input tensor A has shape (M, K) or (K, M),
input tensor B has shape (K, N) or (N, K), input tensor C is broadcastable to shape (M, N),
and output tensor Y has shape (M, N). A will be transposed before doing the
computation if attribute transA is non-zero, same for B and transB.
This operator supports **unidirectional broadcasting** (tensor C should be unidirectional broadcastable to tensor A * B); for more details please check [the doc](Broadcasting.md).
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�
XYGlobalAveragePool"GlobalAveragePool*$
X-typesJfloatJfloat16Jdouble�2�
 GlobalAveragePool consumes an input tensor X and applies average pooling across
 the values in the same channel. This is equivalent to AveragePool with kernel size
 equal to the spatial dimension of input tensor.
�
XYGlobalLpPool"GlobalLpPool*
p�*$
X-typesJfloatJfloat16Jdouble�2�
 GlobalLpPool consumes an input tensor X and applies lp pool pooling across
 the values in the same channel. This is equivalent to LpPool with kernel size
 equal to the spatial dimension of input tensor.
�
XYGlobalMaxPool"GlobalMaxPool*$
X-typesJfloatJfloat16Jdouble�2�
 GlobalMaxPool consumes an input tensor X and applies max pooling across
 the values in the same channel. This is equivalent to MaxPool with kernel size
 equal to the spatial dimension of input tensor.
�"
InputsOutputsGradient"Gradient*	
xs" �*
y" �*	
zs" �*�
Inputs-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�!
Gradient operator computes the partial derivatives of a specific tensor w.r.t.
some other tensors. This operator is widely used in gradient-based training
algorithms. To illustrate its use, let's consider a computation graph,

```
X -----.
       |
       v
W --> Conv --> H --> Gemm --> Y
                      ^
                      |
                      Z
```

, where W and Z are trainable tensors. Note that operators' attributes are
omitted for the sake of simplicity. Let dY/dW (dY/dZ) be the gradient of
Y with respect to W (Z). The user can compute gradient by inserting Gradient
operator to form another graph shown below.

```
W --> Conv --> H --> Gemm --> Y
|      ^              ^
|      |              |
|      X              Z
|      |              |
|      |   .----------'
|      |   |  (W/Z/X is the 1st/2nd/3rd input of Gradient as shown in
|      |   |   "xs" followed by "zs")
|      v   v
'---> Gradient(xs=["W", "Z"], zs=["X"], y="Y")
       |   |
       |   '-----------------------------------> dY/dW (1st output of Gradient)
       |
       '---------------------------------------> dY/dZ (2nd output of Gradient)
```

By definition, the tensor "y" is a function of independent variables in "xs"
and "zs". Since we only compute the gradient of "y" w.r.t. the differentiable
variables in "xs", this Gradient only outputs dY/dW and dY/dZ. Note that "H"
cannot appear in "xs" and "zs". The reason is that "H" can be determined by
tensors "W" and "X" and therefore "H" is not an independent variable.

All outputs are optional. If needed, for example, user can assign an empty
string to the 1st output name of that Gradient to skip the generation of dY/dW.
Note that the concept of optional outputs can also be found in ONNX's RNN, GRU,
and LSTM.

Gradient operator can compute derivative against intermediate tensors. For
example, the gradient of Y with respect to H can be done via

```
W --> Conv --> H --> Gemm --> Y
       ^       |      ^
       |       |      |
       X       |      Z
       .-------'      |
       |   .----------'
       |   | (H/Z is the 1st/2nd input of Gradient as shown in "xs")
       v   v
      Gradient(xs=["H", "Z"], y="Y")
       |   |
       |   '-----------------------------------> dY/dH (1st output of Gradient)
       |
       '---------------------------------------> dY/dZ (2nd output of Gradient)
```

It is possible to represent high-order differentiation using Gradient operators.
For example, given the following linear model:

```
W --> Gemm --> Y --> Loss --> O
       ^              ^
       |              |
       X              L
```

To compute the 2nd order derivative of O with respect to W (denoted by
d^2O/dW^2), one can do

```
W --> Gemm --> Y --> Loss --> O
|      ^              ^
|      |              |
|      X .------------L
|      | |            |
|      | |            v
+------+-+> Gradient(xs=["X", "W"], zs=["L"], y="O") ---> dO/dX (1st output of Gradient)
|      | |    |
|      | |    '---> dO/dW (2nd output of Gradient)
|      v v
'---> Gradient(xs=["X", "W"], zs=["L"], y="dO/dW") ---> d(dO/dW)dX (1st output of
       |                                                  Gradient)
       |
       |
       '---> d^2O/dW^2 (2nd output of Gradient)
```

The tensors named in attributes "xs", "zs", and "y" define the differentiated
computation graph, and the inputs to Gradient node define the values at
which the gradient is computed. We can feed different tensors to the identified
graph. For example, one can compute the gradient of Y with respect to H at
a specific value of H, H_1, by providing that value as an input to the Gradient
node.

```
W --> Conv --> H --> Gemm --> Y
       ^              ^
       |              |
       X              Z

          Z_1 (2nd input of Gradient)
           |
           v
H_1 --> Gradient(xs=["H", "Z"], y="Y") ---> dY/dH when H = H_1 and Y = Y_1.
           |
           '------------------------------> dY/dZ (2nd output of Gradient)
```

When the inputs of Gradient are the tensors named in "xs" and "zs", the
computation can be optimized. More specifically, intermediate variables in
forward pass can be reused if the gradient is computed via reverse-mode
auto-differentiation.


�
A
BCGreater"Greater*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Returns the tensor resulted from performing the `greater` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
A
BCGreaterOrEqual"GreaterOrEqual*^
A-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*^
B-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Returns the tensor resulted from performing the `greater_equal` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
XYHardSigmoid"HardSigmoid*
alpha��L>�*
beta   ?�*$
X-typesJfloatJfloat16Jdouble�2�
HardSigmoid takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the HardSigmoid function, y = max(0, min(1, alpha * x + beta)),
is applied to the tensor elementwise.

�
XY	HardSwish"	HardSwish*$
X-typesJfloatJfloat16Jdouble�2�
HardSwish takes one input data (Tensor<T>) and produces one output data (Tensor<T>) where
the HardSwish function, y = x * max(0, min(1, alpha * x + beta)) = x * HardSigmoid<alpha, beta>(x),
where alpha = 1/6 and beta = 0.5, is applied to the tensor elementwise.

�
inputoutputHardmax"Hardmax*
axis����������*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2�
The operator computes the hardmax values for the given input:

 Hardmax(element in input, axis) = 1 if the element is the first maximum value along the specified axis, 0 otherwise

The input does not need to explicitly be a 2D vector. The "axis" attribute
indicates the dimension along which Hardmax will be performed.
The output tensor has the same shape
and contains the Hardmax values of the corresponding input.

�
inputoutputIdentity"Identity*�
input-typesJint8JboolJseq(float16Jint32JdoubleJuint64Juint16J	seq(uint8J	seq(floatJ	seq(int32JfloatJstringJ
seq(stringJbfloat16Jint16J
complex128Jseq(boolJ
seq(uint64J
seq(doubleJseq(complex128J	seq(int16J
seq(uint32Jseq(int8J	seq(int64Jseq(complex64Jfloat16J	complex64J
seq(uint16Juint8Jint64Juint32�2Identity operator
f
condoutputsIf"If*
else_branch" �*
then_branch" �*

cond-typesJbool�2If conditional
�	
XYImputer"Imputer*
imputed_value_floats" �*
imputed_value_int64s" �*
replaced_value_float    �*
replaced_value_int64 �*)
X-typesJfloatJint64JdoubleJint32�2�
    Replaces inputs that equal one value with another, leaving all other elements alone.<br>
    This operator is typically used to replace missing values in situations where they have a canonical
    representation, such as -1, 0, NaN, or some extreme value.<br>
    One and only one of imputed_value_floats or imputed_value_int64s should be defined -- floats if the input tensor
    holds floats, integers if the input tensor holds integers. The imputed values must all fit within the
    width of the tensor element type. One and only one of the replaced_value_float or replaced_value_int64 should be defined,
    which one depends on whether floats or integers are being processed.<br>
    The imputed_value attribute length can be 1 element, or it can have one element per input feature.<br>In other words, if the input tensor has the shape [*,F], then the length of the attribute array may be 1 or F. If it is 1, then it is broadcast along the last dimension and applied to each feature.

�
input
scale
BoutputInstanceNormalization"InstanceNormalization*
epsilon��'7�*(
input-typesJfloatJfloat16Jdouble�*(
scale-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�2�
Carries out instance normalization as described in the paper
https://arxiv.org/abs/1607.08022.

y = scale * (x - mean) / sqrt(variance + epsilon) + B,
where mean and variance are computed per instance per channel.


�
XYIsInf"IsInf*
detect_negative�*
detect_positive�*
X-typesJfloatJdouble�2/Map infinity to true and other values to false.
r
XYIsNaN"IsNaN*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2,Returns which elements of the input are NaN.
�
XYLRN"LRN*
alpha��8�*
beta  @?�*
bias  �?�*
size" �*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Local Response Normalization proposed in the [AlexNet paper](https://papers.nips.cc/paper/4824-imagenet-classification-with-deep-convolutional-neural-networks.pdf).
It normalizes over local input regions.
The local region is defined across the channels. For an element X[n, c, d1, ..., dk] in a tensor
of shape (N x C x D1 x D2, ..., Dk), its region is
{X[n, i, d1, ..., dk] | max(0, c - floor((size - 1) / 2)) <= i <= min(C - 1, c + ceil((size - 1) / 2))}.

square_sum[n, c, d1, ..., dk] = sum(X[n, i, d1, ..., dk] ^ 2),
where max(0, c - floor((size - 1) / 2)) <= i <= min(C - 1, c + ceil((size - 1) / 2)).

Y[n, c, d1, ..., dk] = X[n, c, d1, ..., dk] / (bias + alpha / size * square_sum[n, c, d1, ..., dk] ) ^ beta

�
X
W
R
B
sequence_lens
	initial_h
	initial_c
PYY_hY_cLSTM"LSTM*
activation_alpha" �*
activation_beta" �*
activations" �*
clip" �*
	direction"forward�*
hidden_size" �*
input_forget �*
layout �*$
X-typesJfloatJfloat16Jdouble�*$
W-typesJfloatJfloat16Jdouble�*$
R-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�*
sequence_lens-typesJint32�*,
initial_h-typesJfloatJfloat16Jdouble�*,
initial_c-typesJfloatJfloat16Jdouble�*$
P-typesJfloatJfloat16Jdouble�2�
Computes an one-layer LSTM. This operator is usually supported via some
custom implementation such as CuDNN.

Notations:

`X` - input tensor

`i` - input gate

`o` - output gate

`f` - forget gate

`c` - cell gate

`t` - time step (t-1 means previous time step)

`W[iofc]` - W parameter weight matrix for input, output, forget, and cell gates

`R[iofc]` - R recurrence weight matrix for input, output, forget, and cell gates

`Wb[iofc]` - W bias vectors for input, output, forget, and cell gates

`Rb[iofc]` - R bias vectors for input, output, forget, and cell gates

`P[iof]`  - P peephole weight vector for input, output, and forget gates

`WB[iofc]` - W parameter weight matrix for backward input, output, forget, and cell gates

`RB[iofc]` - R recurrence weight matrix for backward input, output, forget, and cell gates

`WBb[iofc]` - W bias vectors for backward input, output, forget, and cell gates

`RBb[iofc]` - R bias vectors for backward input, output, forget, and cell gates

`PB[iof]`  - P peephole weight vector for backward input, output, and forget gates

`H` - Hidden state

`num_directions` - 2 if direction == bidirectional else 1

Activation functions:

  Relu(x)                - max(0, x)

  Tanh(x)                - (1 - e^{-2x})/(1 + e^{-2x})

  Sigmoid(x)             - 1/(1 + e^{-x})

  (NOTE: Below are optional)

  Affine(x)              - alpha*x + beta

  LeakyRelu(x)           - x if x >= 0 else alpha * x

  ThresholdedRelu(x)     - x if x >= alpha else 0

  ScaledTanh(x)          - alpha*Tanh(beta*x)

  HardSigmoid(x)         - min(max(alpha*x + beta, 0), 1)

  Elu(x)                 - x if x >= 0 else alpha*(e^x - 1)

  Softsign(x)            - x/(1 + |x|)

  Softplus(x)            - log(1 + e^x)

Equations (Default: f=Sigmoid, g=Tanh, h=Tanh):

  - it = f(Xt*(Wi^T) + Ht-1*(Ri^T) + Pi (.) Ct-1 + Wbi + Rbi)

  - ft = f(Xt*(Wf^T) + Ht-1*(Rf^T) + Pf (.) Ct-1 + Wbf + Rbf)

  - ct = g(Xt*(Wc^T) + Ht-1*(Rc^T) + Wbc + Rbc)

  - Ct = ft (.) Ct-1 + it (.) ct

  - ot = f(Xt*(Wo^T) + Ht-1*(Ro^T) + Po (.) Ct + Wbo + Rbo)

  - Ht = ot (.) h(Ct)
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�
XYLabelEncoder"LabelEncoder*
default_float   ��*
default_int64����������*
default_string"_Unused�*
keys_floats" �*
keys_int64s" �*
keys_strings" �*
values_floats" �*
values_int64s" �*
values_strings" �*"
X-typesJfloatJint64Jstring�2�	
    Maps each element in the input tensor to another value.<br>
    The mapping is determined by the two parallel attributes, 'keys_*' and
    'values_*' attribute. The i-th value in the specified 'keys_*' attribute
    would be mapped to the i-th value in the specified 'values_*' attribute. It
    implies that input's element type and the element type of the specified
    'keys_*' should be identical while the output type is identical to the
    specified 'values_*' attribute. If an input element can not be found in the
    specified 'keys_*' attribute, the 'default_*' that matches the specified
    'values_*' attribute may be used as its output value.<br>
    Let's consider an example which maps a string tensor to an integer tensor.
    Assume and 'keys_strings' is ["Amy", "Sally"], 'values_int64s' is [5, 6],
    and 'default_int64' is '-1'.  The input ["Dori", "Amy", "Amy", "Sally",
    "Sally"] would be mapped to [-1, 5, 5, 6, 6].<br>
    Since this operator is an one-to-one mapping, its input and output shapes
    are the same. Notice that only one of 'keys_*'/'values_*' can be set.<br>
    For key look-up, bit-wise comparison is used so even a float NaN can be
    mapped to a value in 'values_*' attribute.<br>

�
XY	LeakyRelu"	LeakyRelu*
alpha
�#<�*$
X-typesJfloatJfloat16Jdouble�2�
LeakyRelu takes input data (Tensor<T>) and an argument alpha, and produces one
output data (Tensor<T>) where the function `f(x) = alpha * x for x < 0`,
`f(x) = x for x >= 0`, is applied to the data tensor elementwise.

�
A
BCLess"Less*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Returns the tensor resulted from performing the `less` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
A
BCLessOrEqual"LessOrEqual*^
A-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*^
B-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Returns the tensor resulted from performing the `less_equal` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
XYZLinearClassifier"LinearClassifier*
classlabels_ints" �*
classlabels_strings" �*
coefficients" �*

intercepts" �*
multi_class �*
post_transform"NONE�*)
X-typesJint32Jint64JfloatJdouble�2
    Linear classifier

�
XYLinearRegressor"LinearRegressor*
coefficients" �*

intercepts" �*
post_transform"NONE�*
targets�*)
X-typesJint32Jint64JfloatJdouble�2�
    Generalized linear regression evaluation.<br>
    If targets is set to 1 (default) then univariate regression is performed.<br>
    If targets is set to M then M sets of coefficients must be passed in as a sequence
    and M results will be output for each input n in N.<br>
    The coefficients array is of length n, and the coefficients for each target are contiguous.
    Intercepts are optional but if provided must match the number of targets.

�
inputoutputLog"Log*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2E
Calculates the natural log of the given input tensor, element-wise.

�
inputoutput
LogSoftmax"
LogSoftmax*
axis����������*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2�
The operator computes the log of softmax values for the given input:

 LogSoftmax(input, axis) = Log(Softmax(input, axis=axis))

The input does not need to explicitly be a 2D vector. The "axis" attribute
indicates the dimension along which LogSoftmax will be performed.
The output tensor has the same shape
and contains the LogSoftmax values of the corresponding input.

�0
M
cond
	v_initialv_final_and_scan_outputsLoop"Loop*
body" �*
M-typesJint64�*

cond-typesJbool�*�
v_initial-typesJint8JboolJseq(float16Jint32JdoubleJuint64Juint16J	seq(uint8J	seq(floatJ	seq(int32JfloatJstringJ
seq(stringJseq(boolJint16J
complex128J
seq(uint64J
seq(doubleJseq(complex128J	seq(int16J
seq(uint32Jseq(int8J	seq(int64Jseq(complex64Jfloat16J	complex64J
seq(uint16Juint8Jint64Juint32�2�-
Generic Looping construct. This loop has multiple termination conditions:

1) Trip count. Iteration count specified at runtime. Set by
   specifying the input M. Optional. Set to empty string to omit.
   Note that a static trip count (specified at graph construction time) can be
   specified by passing in a constant node for input M.
2) Loop termination condition. This is an input to the op that determines
   whether to run the first iteration and also a loop-carried dependency for
   the body graph. The body graph must yield a value for the condition variable,
   whether this input is provided or not.

This table summarizes the operating modes of this operator with equivalent
C-style code:

    Operator inputs defined as (max_trip_count, condition_var).

    input ("", ""):
        for (int i=0; ; ++i) {
          cond = ... // Note this value is ignored, but is required in the body
        }

    input ("", cond) // Note this is analogous to a while loop
        bool cond = ...;
        for (int i=0; cond; ++i) {
          cond = ...;
        }

    input ("", 1) // Note this is analogous to a do-while loop
        bool cond = true
        for (int i=0; cond; ++i) {
          cond = ...;
        }

    input (trip_count, "") // Note this is analogous to a for loop
        int trip_count = ...
        for (int i=0; i < trip_count; ++i) {
          cond = ...; // ignored
        }

    input (trip_count, cond)
        int trip_count = ...;
        bool cond = ...;
        for (int i=0; i < trip_count && cond; ++i) {
          cond = ...;
        }


*Sample usage - cond as well as trip count*

    graph predict-net {
      %a = Constant[value = <Scalar Tensor [3]>]()
      %b = Constant[value = <Scalar Tensor [6]>]()
      %keepgoing = Constant[value = <Scalar Tensor [1]>]()
      %max_trip_count = Constant[value = <Scalar Tensor [10]>]()
      %keepgoing_out, %b_out, %user_defined_vals = Loop[body = <graph body-net>](%max_trip_count, %keepgoing, %b)
      return
    }

    graph body-net (
      %i[INT32, scalar]           // iteration number
      %keepgoing_in[BOOL, scalar] // incoming loop-termination-condition; not used
      %b_in[INT32, scalar]        // incoming value of loop-carried-dependency b
    ) {
      %my_local = Add(%a, %b_in)
      %b_out = Sub(%a, %b_in) // outgoing value of loop-carried-dependency b
      %keepgoing_out = Greater(%my_local, %b_out) // outgoing loop-termination-condition
      %user_defined_val = Add(%b_in, %b_in) // scan-output value to be accumulated
      return %keepgoing_out, %b_out, %user_defined_val
    }

*Sample equivalent C code*

    {
      /* User-defined code (enclosing scope) */
      int a = 3, b = 6;
      bool keepgoing = true; // Analogous to input cond
      /* End user-defined code */

      /* Implicitly-defined code */
      const int max_trip_count = 10; // Analogous to input M
      int user_defined_vals[]; // Imagine this is resizable
      /* End implicitly-defined code */
      /* initialize loop-carried variables and scan-output variables */
      bool keepgoing_out = keepgoing
      int b_out = b

      for (int i=0; i < max_trip_count && keepgoing_out; ++i) {
        /* Implicitly-defined code: bind actual parameter values
           to formal parameter variables of loop-body */
        bool keepgoing_in = keepgoing_out;
        bool b_in = b_out;

        /* User-defined code (loop body) */
        int my_local = a + b_in; // Reading value "a" from the enclosing scope is fine
        b_out = a - b_in;
        keepgoing_out = my_local > b_out;
        user_defined_val = b_in + b_in; // b_in and b_out are different variables
        /* End user-defined code */

        /* Implicitly defined-code */
        user_defined_vals[i] = user_defined_val // accumulate scan-output values
      }
      // int t = my_local; // Can't do this. my_local is not accessible here.

      // The values below are bound to the output variables of the loop and therefore accessible
      // b_out; user_defined_vals; keepgoing_out;
    }

There are several things of note in this code snippet:

1) Values from the enclosing scope (i.e. variable "a" here) are in scope and can
   be referenced in the inputs of the loop.
2) Any values computed in the loop body that needs to be used in a subsequent
   iteration or after the loop are modelled using a pair of variables in the loop-body,
   consisting of an input variable (eg., b_in) and an output variable (eg., b_out).
   These are referred to as loop-carried dependences. The loop operation node
   supplies the input value of the input variable for the first iteration, and
   returns the output value of the output variable produced by the final
   iteration.
3) Scan_output variables are used to implicitly concatenate values computed across
   all the iterations. In the above example, the value of user_defined_val computed
   over all iterations are concatenated and returned as the value of user_defined_vals
   after the loop.
4) Values created in the body cannot be accessed in the enclosing scope,
   except using the mechanism described above.

Note that the semantics of this op support "diagonal" or "wavefront" execution.
(See Step 3 here for an example:
https://devblogs.nvidia.com/optimizing-recurrent-neural-networks-cudnn-5/).
Frontends should emit multi-layer RNNs as a series of While operators (with
time being the inner looping dimension), with each successive layer consuming
the scan_outputs from the previous layer, possibly going through several
point-wise operators (e.g. dropout, residual connections, linear layer).

The input/output of subgraph (produced by loop node) matching is based on order instead of name. The implementation will figure out the names based on this order.

�
inputoutputLpNormalization"LpNormalization*
axis����������*
p�*(
input-typesJfloatJfloat16Jdouble�2A
Given a matrix, apply Lp-normalization along the provided axis.

�
XYLpPool"LpPool*
auto_pad"NOTSET�*
kernel_shape" �*
p�*
pads" �*
strides" �*$
X-typesJfloatJfloat16Jdouble�2�
 LpPool consumes an input tensor X and applies Lp pooling across
 the tensor according to kernel sizes, stride sizes, and pad lengths.
 Lp pooling consisting of computing the Lp norm on all values of a subset
 of the input tensor according to the kernel size and downsampling the
 data into the output tensor Y for further processing.
�
A
BYMatMul"MatMul*L
A-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�*L
B-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2~
Matrix product that behaves like numpy.matmul: https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.matmul.html

�
A
B
a_zero_point
b_zero_pointYMatMulInteger"MatMulInteger*
A-typesJuint8Jint8�*
B-typesJuint8Jint8�*$
a_zero_point-typesJuint8Jint8�*$
b_zero_point-typesJuint8Jint8�2�
Matrix product that behaves like numpy.matmul: https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.matmul.html.
The production MUST never overflow. The accumulation may overflow if and only if in 32 bits.

�
data_0maxMax"Max*m
data_0-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Element-wise max of each of the input tensors (with Numpy-style broadcasting support).
All inputs and outputs must have the same data type.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
XYIndicesMaxPool"MaxPool*
auto_pad"NOTSET�*
	ceil_mode �*
	dilations" �*
kernel_shape" �*
pads" �*
storage_order �*
strides" �*1
X-typesJint8JdoubleJfloat16Juint8Jfloat�2�
 MaxPool consumes an input tensor X and applies max pooling across
 the tensor according to kernel sizes, stride sizes, and pad lengths.
 max pooling consisting of computing the max on all values of a
 subset of the input tensor according to the kernel size and downsampling the
 data into the output tensor Y for further processing. The output spatial shape will be following:
 ```
 output_spatial_shape[i] = floor((input_spatial_shape[i] + pad_shape[i] - ((kernel_spatial_shape[i] - 1) * dilations[i] + 1)) / strides_spatial_shape[i] + 1)
 ```
 or
 ```
 output_spatial_shape[i] = ceil((input_spatial_shape[i] + pad_shape[i] - ((kernel_spatial_shape[i] - 1) * dilations[i] + 1)) / strides_spatial_shape[i] + 1)
 ```
 if ceil_mode is enabled

 ```
 * pad_shape[i] is sum of pads along axis i
 ```

 `auto_pad` is a DEPRECATED attribute. If you are using them currently, the output spatial shape will be following:
 ```
 VALID: output_spatial_shape[i] = ceil((input_spatial_shape[i] - ((kernel_spatial_shape[i] - 1) * dilations[i] + 1) + 1) / strides_spatial_shape[i])
 SAME_UPPER or SAME_LOWER: output_spatial_shape[i] = ceil(input_spatial_shape[i] / strides_spatial_shape[i])
 ```
 And pad shape will be following if `SAME_UPPER` or `SAME_LOWER`:
 ```
 pad_shape[i] = (output_spatial_shape[i] - 1) * strides_spatial_shape[i] + ((kernel_spatial_shape[i] - 1) * dilations[i] + 1) - input_spatial_shape[i]
 ```
 The output of each pooling window is maximum number of elements exclude pad. 
 
�
X
roisY
MaxRoiPool"
MaxRoiPool*
pooled_shape" �*
spatial_scale  �?�*$
X-typesJfloatJfloat16Jdouble�*'

rois-typesJfloatJfloat16Jdouble�2�
 ROI max pool consumes an input tensor X and region of interests (RoIs) to
 apply max pooling across each RoI, to produce output 4-D tensor of shape
 (num_rois, channels, pooled_shape[0], pooled_shape[1]).
�
X
I
output_shapeoutput	MaxUnpool"	MaxUnpool*
kernel_shape" �*
pads" �*
strides" �*$
X-typesJfloatJfloat16Jdouble�*
I-typesJint64�*
output_shape-typesJint64�2�

MaxUnpool essentially computes the partial inverse of the MaxPool op.
 The input information to this op is typically the the output information from a MaxPool op. The first
 input tensor X is the tensor that needs to be unpooled, which is typically the pooled tensor (first output)
 from MaxPool. The second input tensor, I, contains the indices to the (locally maximal) elements corrsponding
 to the elements in the first input tensor X. Input tensor I is typically the second output of the MaxPool op.
 The third (optional) input is a tensor that specifies the output size of the unpooling operation.

MaxUnpool is intended to do 'partial' inverse of the MaxPool op. 'Partial' because all the non-maximal
 values from the original input to MaxPool are set to zero in the output of the MaxUnpool op. Pooling
 the result of an unpooling operation should give back the original input to the unpooling op.

MaxUnpool can produce the same output size for several input sizes, which makes unpooling op ambiguous.
 The third input argument, output_size, is meant to disambiguate the op and produce output tensor of
 known/predictable size.

In addition to the inputs, MaxUnpool takes three attributes, namely kernel_shape, strides, and pads,
 which define the exact unpooling op. The attributes typically have the same values as the corrsponding
 pooling op that the unpooling op is trying to invert.

�
data_0meanMean"Mean*3
data_0-typesJfloatJfloat16Jbfloat16Jdouble�2�
Element-wise mean of each of the input tensors (with Numpy-style broadcasting support).
All inputs and outputs must have the same data type.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
XYMeanVarianceNormalization"MeanVarianceNormalization*
axes@ @@�*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
      A MeanVarianceNormalization Function: Perform mean variance normalization
      on the input tensor X using formula: <br/> ``` (X-EX)/sqrt(E(X-EX)^2) ```

�
data_0minMin"Min*m
data_0-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Element-wise min of each of the input tensors (with Numpy-style broadcasting support).
All inputs and outputs must have the same data type.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
A
BCMod"Mod*
fmod �*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
  Performs element-wise binary modulus (with Numpy-style broadcasting support).
    The sign of the remainder is the same as that of the Divisor.

    Mod operator can also behave like C fmod() or numpy.fmod. In this case, the sign of the remainder however, will be the same as the Dividend
    (in contrast to integer mod). To force a behavior like numpy.fmod() an 'fmod' Attribute is provided.
    This attribute is set to 0 by default causing the behavior to be like integer mod.
    Setting this attribute to 1 causes the remainder to be calculated similar to that of numpy.fmod().

    If the input type is floating point, then `fmod` attribute must be set to 1.

    In case of dividend being zero, the results will be platform dependent.

  This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
R
T
inputsoutputsMomentum"Momentum*
alpha" �*
beta" �*
mode" �*
norm_coefficient" �*
R-typesJfloatJdouble�*
T-typesJint64�* 
inputs-typesJfloatJdouble�2�
    Compute one iteration of stochastic gradient update with momentum.
    This operator can conduct the optimization of multiple tensor variables.

    Let's define the behavior of this operator. As you can imagine, SG with momentum requires
    several parameters:

     - The learning-rate "R".
     - The update count "T". That is, the number of conducted training iterations. It should
       be zero in the first training iteration.
     - A L2-norm regularization coefficient "norm_coefficient".
     - A decay coefficient of previous accumulated gradient (i.e., momentum) "alpha".
     - The scaling coefficient of current gradient "beta".
     - An attribute to choose either standard momentum or Nesterov's momentum "mode" should
       be used.

    For the sake of simplicity, assume that there is only one tensor (called "X") to be optimized.
    Other necessary inputs are "X"'s gradient (called "G") and "X"'s momentum (called "V"). This
    Momentum operator maps all these inputs to the new value of "X" (called "X_new") and its new
    momentum (called "V_new").

    This operator supports two different momentum algorithms. Set the attribute "mode" to
    "nesterov" if Nesterov's momentum is desired. Otherwise, set the attribute "model" to
    "standard" to use standard momentum. Computation details are described subsequently.

    Let "+", "-", "*", and "/" are all element-wise operations with numpy-style broadcasting.

    Pseudo code for SG with standard momentum:

      // Add gradient of 0.5 * norm_coefficient * ||X||^2, where ||X|| is the sum of squared
      // values of all elements in X.
      G_regularized = norm_coefficient * X + G

      // In the first training iteration, beta should always be 1.
      beta_adjusted = T > 0 ? beta : 1

      // Compute the current momentum based on previous momentum and the current gradient.
      V_new = alpha * V + beta_adjusted * G_regularized

      // Update X.
      X_new = X - R * V_new

    Pseudo code for SG with Nesterov's momentum:

      // Add gradient of 0.5 * norm_coefficient * ||X||^2, where ||X|| is the sum of squared
      // values of all elements in X.
      G_regularized = norm_coefficient * X + G;

      // In the first training iteration, beta should always be 1.
      beta_adjusted = T > 0 ? beta : 1

      // Compute the current momentum based on previous momentum and the current gradient.
      V_new = alpha * V + beta_adjusted * G_regularized;

      // Compute final update direction and then update X.
      X_new = X - R * (G_regularized + alpha * V_new)

    If one assign this operators to optimize multiple inputs, for example, "X_1" and "X_2". The same
    pseudo code would be extended to handle all tensors jointly. More specifically, we can view "X" as a
    concatenation of "X_1" and "X_2" (of course, their gradient and accumulate gradient should
    be concatenated too) and then our pseudo code becomes applicable.

�
A
BCMul"Mul*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Performs element-wise binary multiplication (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

(Opset 14 change): Extend supported types to include uint8, int8, uint16, and int16.

�
inputoutputMultinomial"Multinomial*
dtype�*
sample_size�*
seed" �*(
input-typesJfloatJfloat16Jdouble�2
Generate a tensor of samples from a multinomial distribution according to the probabilities
of each of the possible outcomes.

�
XYNeg"Neg*I
X-typesJbfloat16Jint16Jint8Jint32JdoubleJfloat16JfloatJint64�2�
Neg takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where each element flipped sign, y = -x, is applied to
the tensor elementwise.

�
input
target
weightlossNegativeLogLikelihoodLoss"NegativeLogLikelihoodLoss*
ignore_index" �*
	reduction"mean�*(
input-typesJfloatJfloat16Jdouble�*
target-typesJint32Jint64�*)
weight-typesJfloatJfloat16Jdouble�2�
A NegativeLogLikelihoodLoss operator computes (weighted) negative log likelihood loss.
Its "input" tensor has the shape of (N, C, d1, d2, ..., dk) where k >= 0.
The "input" tensor contains log-probabilities for input[n, :, d_1, d_2,..., d_k] being in a class of [0, C).
The operator's "target" input tensor has the shape of (N, d1, d2, ..., dk). It encodes class labels (one of C classes)
or it may contain a special value (indicated by an attribute ignore_index) for N x d1 x d2 x ... x dk samples.
The loss value for input[n, :, d_1, d_2,...d_k] being classified as class c = target[n][d_1][d_2]...[d_k] is computed as:

    loss[n][d_1][d_2]...[d_k] = -input[n][c][d_1][d_2]...[d_k].

When an optional "weight" is provided, the sample loss is calculated as:

    loss[n][d_1][d_2]...[d_k] = -input[n][c][d_1][d_2]...[d_k] * weight[c].

loss is zero for the case when target-value equals ignore_index.

    loss[n][d_1][d_2]...[d_k] = 0, when target[n][d_1][d_2]...[d_k] = ignore_index

If "reduction" attribute is set to "none", the operator's output will be the above loss with shape (N, d1, d2, ..., dk).
If "reduction" attribute is set to "mean" (the default attribute value), the output loss is (weight) averaged:

    mean(loss), if "weight" is not provided,

or if weight is provided,

    sum(loss) / sum(weight[target[n][d_1][d_2]...[d_k]]]), for all samples.

If "reduction" attribute is set to "sum", the output is a scalar:
    sum(loss).

See also https://pytorch.org/docs/stable/nn.html#torch.nn.NLLLoss.

Example 1:

    // negative log likelihood loss, "none" reduction
    N, C, d1 = 2, 3, 2
    input = [[[1.0, 2.0], [2.0, 2.0], [3.0, 2.0]],
             [[0.0, 1.0], [2.0, 2.0], [1.0, 2]]]
    target = [[2, 1], [0, 2]]

    loss = np.zeros((N, d1))
    for n in range(N):
        for d_1 in range(d1):
            c = target[n][d_1]
            loss[n][d_1] = -input[n][c][d_1]

    // print(loss)
    // [[-3. -2.]
    //  [-0. -2.]]

Example 2:

    // weighted negative log likelihood loss, sum reduction
    N, C, d1 = 2, 3, 2
    input = [[[1.0, 2.0], [2.0, 2.0], [3.0, 2.0]],
            [[0.0, 1.0], [2.0, 2.0], [1.0, 2]]]
    target = [[2, 1], [0, 2]]
    weight = [0.2, 0.3, 0.1]
    loss = np.zeros((N, d1))
    for n in range(N):
        for d_1 in range(d1):
            c = target[n][d_1]
            loss[n][d_1] = -input[n][c][d_1] * weight[c]

    loss = np.sum(loss)
    // print(loss)
    // -1.1

Example 3:

    // weighted negative log likelihood loss, mean reduction
    N, C, d1 = 2, 3, 2
    input = [[[1.0, 2.0], [2.0, 2.0], [3.0, 2.0]],
            [[0.0, 1.0], [2.0, 2.0], [1.0, 2]]]
    target = [[2, 1], [0, 2]]
    weight = [0.2, 0.3, 0.1]
    loss = np.zeros((N, d1))
    weight_total = 0
    for n in range(N):
        for d_1 in range(d1):
            c = target[n][d_1]
            loss[n][d_1] = -input[n][c][d_1] * weight[c]
            weight_total = weight_total + weight[c]

    loss = np.sum(loss) / weight_total
    // print(loss)
    // -1.57

�
boxes
scores
max_output_boxes_per_class
iou_threshold
score_thresholdselected_indicesNonMaxSuppression"NonMaxSuppression*
center_point_box �*
boxes-typesJfloat�*
scores-typesJfloat�*,
 max_output_boxes_per_class-typesJint64�*
iou_threshold-typesJfloat�*!
score_threshold-typesJfloat�2�
Filter out boxes that have high intersection-over-union (IOU) overlap with previously selected boxes.
Bounding boxes with score less than score_threshold are removed. Bounding box format is indicated by attribute center_point_box.
Note that this algorithm is agnostic to where the origin is in the coordinate system and more generally is invariant to
orthogonal transformations and translations of the coordinate system; thus translating or reflections of the coordinate system
result in the same boxes being selected by the algorithm.
The selected_indices output is a set of integers indexing into the input collection of bounding boxes representing the selected boxes.
The bounding box coordinates corresponding to the selected indices can then be obtained using the Gather or GatherND operation.

�
XYNonZero"NonZero*�
X-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
    Returns the indices of the elements that are non-zero
    (in row-major order - by dimension).
    NonZero behaves similar to numpy.nonzero:
    https://docs.scipy.org/doc/numpy/reference/generated/numpy.nonzero.html

�
XY
Normalizer"
Normalizer*
norm"MAX�*)
X-typesJint32Jint64JfloatJdouble�2�
    Normalize the input.  There are three normalization modes, which have the corresponding formulas,
    defined using element-wise infix operators '/' and '^' and tensor-wide functions 'max' and 'sum':<br>
<br>
    Max: Y = X / max(X)<br>
    L1:  Y = X / sum(X)<br>
    L2:  Y = sqrt(X^2 / sum(X^2)}<br>
    In all modes, if the divisor is zero, Y == X.
<br>
    For batches, that is, [N,C] tensors, normalization is done along the C axis. In other words, each row
    of the batch is normalized independently.

^
XYNot"Not*
X-typesJbool�28
Returns the negation of the input tensor element-wise.

�
indices
depth
valuesoutputOneHot"OneHot*
axis����������*d
indices-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*b
depth-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*�
values-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�	
    Produces a one-hot tensor based on inputs.
    The locations represented by the index values in the 'indices' input tensor will have 'on_value'
    and the other locations will have 'off_value' in the output tensor, where 'on_value' and 'off_value'
    are specified as part of required input argument 'values', which is a two-element tensor of format
    [off_value, on_value]. The rank of the output tensor will be one greater than the rank of the
    input tensor. The additional dimension is for one-hot representation. The additional dimension will
    be inserted at the position specified by 'axis'. If 'axis' is not specified then then additional
    dimension will be inserted as the innermost dimension, i.e. axis=-1. The size of the additional
    dimension is specified by required scalar input 'depth'. The type of the output tensor is the same
    as the type of the 'values' input. Any entries in the 'indices' input tensor with values outside
    the range [-depth, depth-1] will result in one-hot representation with all 'off_value' values in the
    output tensor.

    when axis = 0:
    output[input[i, j, k], i, j, k] = 1 for all i, j, k and 0 otherwise.

    when axis = -1:
    output[i, j, k, input[i, j, k]] = 1 for all i, j, k and 0 otherwise.


�
XYOneHotEncoder"OneHotEncoder*
cats_int64s" �*
cats_strings" �*
zeros�*1
X-typesJint32JdoubleJfloatJint64Jstring�2�
    Replace each input element with an array of ones and zeros, where a single
    one is placed at the index of the category that was passed in. The total category count
    will determine the size of the extra dimension of the output array Y.<br>
    For example, if we pass a tensor with a single value of 4, and a category count of 8,
    the output will be a tensor with ``[0,0,0,0,1,0,0,0]``.<br>
    This operator assumes every input feature is from the same set of categories.<br>
    If the input is a tensor of float, int32, or double, the data will be cast
    to integers and the cats_int64s category list will be used for the lookups.

�
A
BCOr"Or*
A-typesJbool�*
B-typesJbool�2�
Returns the tensor resulted from performing the `or` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
X
slopeYPRelu"PRelu*B
X-typesJint32JdoubleJfloat16Juint32JfloatJint64Juint64�*F
slope-typesJint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
PRelu takes input data (Tensor<T>) and slope tensor as input, and produces one
output data (Tensor<T>) where the function `f(x) = slope * x for x < 0`,
`f(x) = x for x >= 0`., is applied to the data tensor elementwise.
This operator supports **unidirectional broadcasting** (tensor slope should be unidirectional broadcastable to input tensor X); for more details please check [the doc](Broadcasting.md).
�
data
pads
constant_valueoutputPad"Pad*
mode"constant�*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*

pads-typesJint64�*�
constant_value-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Given a tensor containing the data to be padded (`data`), a tensor containing the number of start and end pad values for axis (`pads`), (optionally) a `mode`, and (optionally) `constant_value`,
a padded tensor (`output`) is generated.

The three supported `modes` are (similar to corresponding modes supported by `numpy.pad`):

1) `constant`(default) - pads with a given constant value as specified by `constant_value` (which defaults to 0, empty string, or False)

2) `reflect` - pads with the reflection of the vector mirrored on the first and last values of the vector along each axis

3) `edge` - pads with the edge values of array


Example 1 (`constant` mode):
  Insert 0 pads to the beginning of the second dimension.

  data =
  [
      [1.0, 1.2],
      [2.3, 3.4],
      [4.5, 5.7],
  ]

  pads = [0, 2, 0, 0]

  mode = 'constant'

  constant_value = 0.0

  output =
  [
      [0.0, 0.0, 1.0, 1.2],
      [0.0, 0.0, 2.3, 3.4],
      [0.0, 0.0, 4.5, 5.7],
  ]


Example 2 (`reflect` mode):
  data =
  [
      [1.0, 1.2],
      [2.3, 3.4],
      [4.5, 5.7],
  ]

  pads = [0, 2, 0, 0]

  mode = 'reflect'

  output =
  [
      [1.0, 1.2, 1.0, 1.2],
      [2.3, 3.4, 2.3, 3.4],
      [4.5, 5.7, 4.5, 5.7],
  ]


Example 3 (`edge` mode):
  data =
  [
      [1.0, 1.2],
      [2.3, 3.4],
      [4.5, 5.7],
  ]

  pads = [0, 2, 0, 0]

  mode = 'edge'

  output =
  [
      [1.0, 1.0, 1.0, 1.2],
      [2.3, 2.3, 2.3, 3.4],
      [4.5, 4.5, 4.5, 5.7],
  ]


�
X
YZPow"Pow*<
X-typesJbfloat16Jint32JdoubleJfloat16JfloatJint64�*^
Y-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Pow takes input data (Tensor<T>) and exponent Tensor, and
produces one output data (Tensor<T>) where the function `f(x) = x^exponent`,
is applied to the data tensor elementwise.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).
�
x
x_scale
x_zero_point
w
w_scale
w_zero_point
y_scale
y_zero_point
ByQLinearConv"QLinearConv*
auto_pad"NOTSET�*
	dilations" �*
group�*
kernel_shape" �*
pads" �*
strides" �*
x-typesJuint8Jint8�*
x_scale-typesJfloat�*$
x_zero_point-typesJuint8Jint8�*
w-typesJuint8Jint8�*
w_scale-typesJfloat�*$
w_zero_point-typesJuint8Jint8�*
y_scale-typesJfloat�*$
y_zero_point-typesJuint8Jint8�*
B-typesJint32�2�
The convolution operator consumes a quantized input tensor, its scale and zero point,
a quantized filter, its scale and zero point, and output's scale and zero point,
and computes the quantized output. Each scale and zero-point pair must have same shape.
It means they must be either scalars (per tensor) or 1-D tensors (per output channel).
Each input or output and its related zero point must have same type.
When bias is present it must be quantized using scale = input scale * weight scale and
zero point as 0.

�

a
a_scale
a_zero_point
b
b_scale
b_zero_point
y_scale
y_zero_pointyQLinearMatMul"QLinearMatMul*
a-typesJuint8Jint8�*
a_scale-typesJfloat�*$
a_zero_point-typesJuint8Jint8�*
b-typesJuint8Jint8�*
b_scale-typesJfloat�*$
b_zero_point-typesJuint8Jint8�*
y_scale-typesJfloat�*$
y_zero_point-typesJuint8Jint8�2�
Matrix product that behaves like numpy.matmul: https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.matmul.html.
It consumes two quantized input tensors, their scales and zero points, scale and zero point of output, and computes the quantized output.
The quantization formula is y = saturate((x / y_scale) + y_zero_point). For (x / y_scale), it is rounding to nearest ties to even.
Refer to https://en.wikipedia.org/wiki/Rounding for details. Scale and zero point must have same shape.
They must be either scalar (per tensor) or 1-D tensor (per row for 'a' and per column for 'b'). If scale and zero point are 1-D tensor,
the number of elements of scale and zero point tensor of input 'a' and output 'y' should be equal to the number of rows of input 'a',
and the number of elements of scale and zero point tensor of input 'b' should be equal to the number of columns of input 'b'.
Production must never overflow, and accumulation may overflow if and only if in 32 bits.

�
x
y_scale
y_zero_pointyQuantizeLinear"QuantizeLinear*
axis�*
x-typesJint32Jfloat�*
y_scale-typesJfloat�*$
y_zero_point-typesJuint8Jint8�2�
The linear quantization operator. It consumes a high precision tensor, a scale, and a zero point to compute the low precision / quantized tensor. The scale factor can be a scalar
(per-tensor/layer quantization), or a 1-D tensor for per-axis quantization. The quantization formula is y = saturate ((x / y_scale) + y_zero_point).
For saturation, it saturates to [0, 255] if it's uint8, or [-128, 127] if it's int8.
For (x / y_scale), it's rounding to nearest ties to even. Refer to https://en.wikipedia.org/wiki/Rounding for details. 'y_zero_point' and 'y' must have same type.

�
X
W
R
B
sequence_lens
	initial_hYY_hRNN"RNN*
activation_alpha" �*
activation_beta" �*
activationsJTanhJTanh�*
clip" �*
	direction"forward�*
hidden_size" �*
layout �*$
X-typesJfloatJfloat16Jdouble�*$
W-typesJfloatJfloat16Jdouble�*$
R-typesJfloatJfloat16Jdouble�*$
B-typesJfloatJfloat16Jdouble�*
sequence_lens-typesJint32�*,
initial_h-typesJfloatJfloat16Jdouble�2�
Computes an one-layer simple RNN. This operator is usually supported
via some custom implementation such as CuDNN.

Notations:

`X` - input tensor

`i` - input gate

`t` - time step (t-1 means previous time step)

`Wi` - W parameter weight matrix for input gate

`Ri` - R recurrence weight matrix for input gate

`Wbi` - W parameter bias vector for input gate

`Rbi` - R parameter bias vector for input gate

`WBi` - W parameter weight matrix for backward input gate

`RBi` - R recurrence weight matrix for backward input gate

`WBbi` - WR bias vectors for backward input gate

`RBbi` - RR bias vectors for backward input gate

`H` - Hidden state

`num_directions` - 2 if direction == bidirectional else 1

Activation functions:

  Relu(x)                - max(0, x)

  Tanh(x)                - (1 - e^{-2x})/(1 + e^{-2x})

  Sigmoid(x)             - 1/(1 + e^{-x})

  (NOTE: Below are optional)

  Affine(x)              - alpha*x + beta

  LeakyRelu(x)           - x if x >= 0 else alpha * x

  ThresholdedRelu(x)     - x if x >= alpha else 0

  ScaledTanh(x)          - alpha*Tanh(beta*x)

  HardSigmoid(x)         - min(max(alpha*x + beta, 0), 1)

  Elu(x)                 - x if x >= 0 else alpha*(e^x - 1)

  Softsign(x)            - x/(1 + |x|)

  Softplus(x)            - log(1 + e^x)

Equations (Default: f=Tanh):

  - Ht = f(Xt*(Wi^T) + Ht-1*(Ri^T) + Wbi + Rbi)
This operator has **optional** inputs/outputs. See [the doc](IR.md) for more details about the representation of optional arguments. An empty string may be used in the place of an actual argument's name to indicate a missing argument. Trailing optional arguments (those not followed by an argument that is present) may also be simply omitted.

�outputRandomNormal"RandomNormal*
dtype�*
mean    �*
scale  �?�*
seed" �*
shape" �2�
Generate a tensor with random values drawn from a normal distribution. The shape
of the tensor is specified by the `shape` argument and the parameter of the normal distribution
specified by `mean` and `scale`.

The data type is specified by the 'dtype' argument. The 'dtype' argument must
be one of the data types specified in the 'DataType' enum field in the
TensorProto message.

�
inputoutputRandomNormalLike"RandomNormalLike*
dtype" �*
mean    �*
scale  �?�*
seed" �*�
input-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Generate a tensor with random values drawn from a normal distribution.
The shape of the output tensor is copied from the shape of the input tensor,
and the parameters of the normal distribution are specified by `mean` and `scale`.

The data type is specified by the 'dtype' argument, or copied from the input tensor if not provided.
The 'dtype' argument must be one of the data types specified in the 'DataType' enum field in the
TensorProto message, and be valid as an output type.

�outputRandomUniform"RandomUniform*
dtype�*
high  �?�*
low    �*
seed" �*
shape" �2�
Generate a tensor with random values drawn from a uniform distribution. The shape
of the tensor is specified by the `shape` argument and the range by `low` and `high`.

The data type is specified by the 'dtype' argument. The 'dtype' argument must
be one of the data types specified in the 'DataType' enum field in the
TensorProto message.

�
inputoutputRandomUniformLike"RandomUniformLike*
dtype" �*
high  �?�*
low    �*
seed" �*�
input-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Generate a tensor with random values drawn from a uniform distribution.
The shape of the output tensor is copied from the shape of the input tensor,
and the parameters of the uniform distribution are specified by `low` and `high`.

The data type is specified by the 'dtype' argument, or copied from the input tensor if not provided.
The 'dtype' argument must be one of the data types specified in the 'DataType' enum field in the
TensorProto message and be valid as an output type.

�
start
limit
deltaoutputRange"Range*4
start-typesJint16Jint32JdoubleJfloatJint64�*4
limit-typesJint16Jint32JdoubleJfloatJint64�*4
delta-typesJint16Jint32JdoubleJfloatJint64�2�
Generate a tensor containing a sequence of numbers that begin at `start` and extends by increments of `delta`
up to `limit` (exclusive).

The number of elements in the output of range is computed as below-

`number_of_elements = max( ceil( (limit - start) / delta ) , 0 )`

The pseudocode determining the contents of the output is shown below-

`for(int i=0; i<number_of_elements; ++i)`

`{`

`    output[i] =  start + (i * delta);  `

`}`

`Example 1`
Inputs: start = 3, limit = 9, delta = 3
Output: [3, 6]

`Example 2`
Inputs: start = 10, limit = 4, delta = -2
Output: [10, 8, 6]


�
XY
Reciprocal"
Reciprocal*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Reciprocal takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the reciprocal is, y = 1/x, is applied to
the tensor elementwise.

�
datareducedReduceL1"ReduceL1*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the L1 norm of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareducedReduceL2"ReduceL2*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the L2 norm of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareducedReduceLogSum"ReduceLogSum*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the log sum of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareducedReduceLogSumExp"ReduceLogSumExp*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the log sum exponent of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareduced	ReduceMax"	ReduceMax*
axes" �*
keepdims�*\

data-typesJbfloat16Jint8Juint8Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the max of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareduced
ReduceMean"
ReduceMean*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the mean of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareduced	ReduceMin"	ReduceMin*
axes" �*
keepdims�*\

data-typesJbfloat16Jint8Juint8Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the min of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareduced
ReduceProd"
ReduceProd*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the product of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
data
axesreduced	ReduceSum"	ReduceSum*
keepdims�*
noop_with_empty_axes �*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�*

axes-typesJint64�2�
Computes the sum of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
datareducedReduceSumSquare"ReduceSumSquare*
axes" �*
keepdims�*O

data-typesJbfloat16Jint32JdoubleJfloat16Juint32JfloatJint64Juint64�2�
Computes the sum square of the input tensor's element along the provided axes. The resulted
tensor has the same rank as the input if keepdims equal 1. If keepdims equal 0, then
the resulted tensor have the reduced dimension pruned.

The above behavior is similar to numpy, with the exception that numpy default keepdims to
False instead of True.
�
XYRelu"Relu*I
X-typesJbfloat16Jint16Jint8Jint32JdoubleJfloat16JfloatJint64�2�
Relu takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the rectified linear function, y = max(0, x), is applied to
the tensor elementwise.

�
data
shapereshapedReshape"Reshape*
	allowzero �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
shape-typesJint64�2�
Reshape the input tensor similar to numpy.reshape.
First input is the data tensor, second input is a shape tensor which specifies the output shape. It outputs the reshaped tensor.
At most one dimension of the new shape can be -1. In this case, the value is
inferred from the size of the tensor and the remaining dimensions. A dimension
could also be 0, in which case the actual dimension value is unchanged (i.e. taken
from the input tensor). If 'allowzero' is set, and the new shape includes 0, the
dimension will be set explicitly to zero (i.e. not taken from input tensor)
�
X
roi
scales
sizesYResize"Resize*/
coordinate_transformation_mode"
half_pixel�*
cubic_coeff_a  @��*
exclude_outside �*
extrapolation_value    �*
mode"nearest�*%
nearest_mode"round_prefer_floor�*�
X-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*&
	roi-typesJfloatJfloat16Jdouble�*
scales-typesJfloat�*
sizes-typesJint64�2�
Resize the input tensor. In general, it calculates every value in the output tensor as a weighted average of neighborhood (a.k.a. sampling locations) in the input tensor.
Each dimension value of the output tensor is:
  output_dimension = floor(input_dimension * (roi_end - roi_start) * scale) if input \"sizes\" is not specified.

�
input
sequence_lensYReverseSequence"ReverseSequence*

batch_axis�*
	time_axis �*�
input-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
sequence_lens-typesJint64�2�	
Reverse batch of sequences having different lengths specified by `sequence_lens`.

For each slice i iterating on batch axis, the operator reverses the first sequence_lens[i] elements on time axis,
and copies elements whose index's beyond sequence_lens[i] to the output. So the output slice i contains reversed
sequences on the first sequence_lens[i] elements, then have original values copied for the other elements.

Example 1:
  input = [[0.0, 4.0, 8.0,  12.0],
           [1.0, 5.0, 9.0,  13.0],
           [2.0, 6.0, 10.0, 14.0],
           [3.0, 7.0, 11.0, 15.0]]
  sequence_lens = [4, 3, 2, 1]
  time_axis = 0
  batch_axis = 1

  output = [[3.0, 6.0, 9.0,  12.0],
            [2.0, 5.0, 8.0,  13.0],
            [1.0, 4.0, 10.0, 14.0],
            [0.0, 7.0, 11.0, 15.0]]

Example 2:
  input = [[0.0,  1.0,  2.0,  3.0 ],
           [4.0,  5.0,  6.0,  7.0 ],
           [8.0,  9.0,  10.0, 11.0],
           [12.0, 13.0, 14.0, 15.0]]
  sequence_lens = [1, 2, 3, 4]
  time_axis = 1
  batch_axis = 0

  output = [[0.0,  1.0,  2.0,  3.0 ],
            [5.0,  4.0,  6.0,  7.0 ],
            [10.0, 9.0,  8.0,  11.0],
            [15.0, 14.0, 13.0, 12.0]]

�
X
rois
batch_indicesYRoiAlign"RoiAlign*
mode"avg�*
output_height�*
output_width�*
sampling_ratio �*
spatial_scale  �?�*$
X-typesJfloatJfloat16Jdouble�*'

rois-typesJfloatJfloat16Jdouble�*
batch_indices-typesJint64�2�
Region of Interest (RoI) align operation described in the
[Mask R-CNN paper](https://arxiv.org/abs/1703.06870).
RoiAlign consumes an input tensor X and region of interests (rois)
to apply pooling across each RoI; it produces a 4-D tensor of shape
(num_rois, C, output_height, output_width).

RoiAlign is proposed to avoid the misalignment by removing
quantizations while converting from original image into feature
map and from feature map into RoI feature; in each ROI bin,
the value of the sampled locations are computed directly
through bilinear interpolation.

�
XYRound"Round*$
X-typesJfloatJfloat16Jdouble�2�
Round takes one input Tensor and rounds the values, element-wise, meaning
it finds the nearest integer for each value.
In case of halfs, the rule is to round them to the nearest even integer.
The output tensor has the same shape and type as the input.

Examples:
```
round([0.9]) = [1.0]
round([2.5]) = [2.0]
round([2.3]) = [2.0]
round([1.5]) = [2.0]
round([-4.5]) = [-4.0]
```

�
XYZSVMClassifier"SVMClassifier*
classlabels_ints" �*
classlabels_strings" �*
coefficients" �*
kernel_params" �*
kernel_type"LINEAR�*
post_transform"NONE�*
prob_a" �*
prob_b" �*

rho" �*
support_vectors" �*
vectors_per_class" �*)
X-typesJfloatJint64JdoubleJint32�2'
    Support Vector Machine classifier

�
XYSVMRegressor"SVMRegressor*
coefficients" �*
kernel_params" �*
kernel_type"LINEAR�*

n_supports �*
	one_class �*
post_transform"NONE�*

rho" �*
support_vectors" �*)
X-typesJint32Jint64JfloatJdouble�2W
    Support Vector Machine regression prediction and one-class SVM anomaly detection.

�
XYScaler"Scaler*
offset" �*
scale" �*)
X-typesJint32Jint64JfloatJdouble�2p
    Rescale input data, for example to standardize features by removing the mean and scaling to unit variance.

�1
initial_state_and_scan_inputsfinal_state_and_scan_outputsScan"Scan*
body" �*
num_scan_inputs" �*
scan_input_axes" �*
scan_input_directions" �*
scan_output_axes" �*
scan_output_directions" �*�
#initial_state_and_scan_inputs-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�.
Scan can be used to iterate over one or more scan_input tensors,
constructing zero or more scan_output tensors. It combines ideas from general recurrences,
functional programming constructs such as scan, fold, map, and zip and is intended to enable
generalizations of RNN-like constructs for sequence-to-sequence processing.
Other tensors (referred to as state_variables here) can be used to carry a state
when iterating from one element to another (similar to hidden-state in RNNs, also referred
to as loop-carried dependences in the context of loops).
Many common usages involve a single scan_input tensor (where functionality
similar to scan, fold and map can be obtained). When more than one scan_input is used,
a behavior similar to zip is obtained.

The attribute body must be a graph, specifying the computation to be performed in
every iteration. It takes as input the current values of the state_variables and
the current iterated element of the scan_inputs. It must return the (updated) values
of the state_variables and zero or more scan_output_element tensors. The values of the
scan_output_element tensors are concatenated over all the iterations to produce the
scan_output values of the scan construct (similar to the concatenated intermediate
hidden-state values of RNN-like constructs). All the output tensors (state_variables as
well as scan_output_element tensors) are required to have the same shape in each iteration
of the loop (a restriction imposed to enable efficient memory allocation).

Note that the iterated element passed to the body subgraph does not have a sequence
axis. It will have a rank one less than the rank of the corresponding scan_input.

The scan operation returns the final values of the state_variables as well as the
scan_outputs.

The optional attribute scan_input_directions specifies the direction (forward or backward)
for each scan input. If this attribute is omitted, all sequences are scanned in the forward
direction. A bidirectional scan may be performed by specifying the same tensor input twice
in the scan_inputs, once with a forward direction, and once with a backward direction.

The scan_output of the operation is produced by concatenating the scan_output_element
values produced by the body in each iteration.  The optional attribute scan_output_directions
specifies the direction in which scan_output is constructed (by appending or prepending the
scan_output_element to scan_output in each iteration) for each scan_output. If this attribute
is omitted, the scan_output_element is appended to the scan_output in each iteration.

The optional attribute scan_input_axes specifies the axis to be scanned for each scan_input.
If omitted, every scan_input will be scanned in axis 0. For example, if axis 0 is the
batch axis and axis 1 is the time axis (to be scanned), specify an axis value of 1.
Note that scanning a non-zero axis may be less efficient than scanning axis zero.

The optional attribute scan_output_axes specifies the axis along which the scan_outputs
are accumulated for each scan_output. For example, if axis 1 is the time axis (to be
scanned) for both inputs and outputs, specify a scan_input axis and scan_output axis
value of 1.

Note that because of the ONNX restriction that only the last parameter of an operator can
be variadic, the initial-states and scan-inputs are listed together as one input parameter.
Similarly, the final-states and scan-outputs are listed together as one output parameter.
The attribute num_scan_inputs indicates the number M of scan-inputs.

The behavior of

    Scan <
        num_scan_inputs = m,
        body = loop-body,
        scan_input_axes = [axis_1, ..., axis_m]
    > (init_1, ..., init_n, scan_1, ..., scan_m)

is equivalent to the following pseudo-code:

    // scan_i.shape[axis_i] denotes the (max) sequence-length of scan_i
    // scan_i.shape[axis_i] is required to be equal to scan_j.shape[axis_j] for all i,j.
    sequence_length = scan_1.shape[axis_1];

    // initialize state-variables
    st_1 = init_1; ... st_n = init_n;
    // initialize scan-output variables: [] denotes an empty tensor
    scan_out_1 = []; ...; scan_out_k = [];
    // identify number of iterations:

    // execute loop
    for (int t = 0; t < sequence_length; ++t) {
        // generate the scan-input elements: the notation T<axis=k>[t] indicates the sub-tensor
        // of rank one less than T obtained by indexing T at position t along axis k.
        si_1 = scan_1<axis=axis_1>[t];
        ... ;
        si_m = scan_m<axis=axis_m>[t];
        // execute loop-body
        st_1, ..., st_n, so_1, ..., so_k = loop-body(st_1, ..., st_n, si_1, ..., si_m)
        // accumulate the scan-output elements
        scan_out_1 = Concat<axis=0>(scan_out_1, so_1); ... ; scan_out_k = Concat<axis=0>(scan_out_k, so_k);
    }

    return st_1, ..., st_n, scan_out_1, ..., scan_out_k;

*Sample usage: Encoding RNN using a Scan*

The following example shows how a simple RNN over an input tensor %X, with weight tensor %Wi,
recurrence weight tensor %Ri, bias tensors %Wbi and %Rbi, and initial hidden-state %H_0 can
be encoded as a ScanLoop. Note that the loop-body is a nested graph, and it directly computes
%Wi, %Ri, %Wbi, and %Rbi (typically constants or initializers in the body graph). If these
values are computed in the outer graph, they need to be passed in as extra state_variables.

    graph rnn-encoding {
      %H_0 = ...
      %X = ...
      %Y_h, %Y = Scan[body = <graph rnn-cell-1>, num_scan_inputs=1](%H_0, %X)
      return %Y, %Y_h
    }

    graph rnn-cell-1 (
      %H_tminus1[FLOAT, tensor]
      %X_t[FLOAT, tensor]
    ) {
      %Wi = ...
      %Ri = ...
      %Wbi = ...
      %Rbi = ...
      %t1 = X_t * (Wi^T)
      %t2 = H_tminus1*(Ri^T)
      %t3 = Add(%t1, %t2)
      %t4 = Add(%t3, %Wbi)
      %t5 = Add(%t4, %Rbi)
      %Ht = Tanh(%t5)
      %Accumulate = Identity(%Ht)
      return %Ht, %Accumulate
    }


�
data
indices
updatesoutputScatter"Scatter*
axis �*�

data-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�* 
indices-typesJint32Jint64�*�
updates-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
This operator is deprecated. Please use ScatterElements, which provides the same functionality.

Scatter takes three inputs `data`, `updates`, and `indices` of the same
rank r >= 1 and an optional attribute axis that identifies an axis of `data`
(by default, the outer-most axis, that is axis 0). The output of the operation
is produced by creating a copy of the input `data`, and then updating its value
to values specified by `updates` at specific index positions specified by
`indices`. Its output shape is the same as the shape of `data`.

For each entry in `updates`, the target index in `data` is obtained by combining
the corresponding entry in `indices` with the index of the entry itself: the
index-value for dimension = axis is obtained from the value of the corresponding
entry in `indices` and the index-value for dimension != axis is obtained from the
index of the entry itself.

For instance, in a 2-D tensor case, the update corresponding to the [i][j] entry
is performed as below:
```
  output[indices[i][j]][j] = updates[i][j] if axis = 0,
  output[i][indices[i][j]] = updates[i][j] if axis = 1,
```

This operator is the inverse of GatherElements. It is similar to Torch's Scatter operation.

Example 1:
```
  data = [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
  ]
  indices = [
      [1, 0, 2],
      [0, 2, 1],
  ]
  updates = [
      [1.0, 1.1, 1.2],
      [2.0, 2.1, 2.2],
  ]
  output = [
      [2.0, 1.1, 0.0]
      [1.0, 0.0, 2.2]
      [0.0, 2.1, 1.2]
  ]
```
Example 2:
```
  data = [[1.0, 2.0, 3.0, 4.0, 5.0]]
  indices = [[1, 3]]
  updates = [[1.1, 2.1]]
  axis = 1
  output = [[1.0, 1.1, 3.0, 2.1, 5.0]]
```

�
data
indices
updatesoutputScatterElements"ScatterElements*
axis �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�* 
indices-typesJint32Jint64�*�
updates-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
ScatterElements takes three inputs `data`, `updates`, and `indices` of the same
rank r >= 1 and an optional attribute axis that identifies an axis of `data`
(by default, the outer-most axis, that is axis 0). The output of the operation
is produced by creating a copy of the input `data`, and then updating its value
to values specified by `updates` at specific index positions specified by
`indices`. Its output shape is the same as the shape of `data`.

For each entry in `updates`, the target index in `data` is obtained by combining
the corresponding entry in `indices` with the index of the entry itself: the
index-value for dimension = axis is obtained from the value of the corresponding
entry in `indices` and the index-value for dimension != axis is obtained from the
index of the entry itself.

For instance, in a 2-D tensor case, the update corresponding to the [i][j] entry
is performed as below:
```
  output[indices[i][j]][j] = updates[i][j] if axis = 0,
  output[i][indices[i][j]] = updates[i][j] if axis = 1,
```

This operator is the inverse of GatherElements. It is similar to Torch's Scatter operation.

Example 1:
```
  data = [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0],
  ]
  indices = [
      [1, 0, 2],
      [0, 2, 1],
  ]
  updates = [
      [1.0, 1.1, 1.2],
      [2.0, 2.1, 2.2],
  ]
  output = [
      [2.0, 1.1, 0.0]
      [1.0, 0.0, 2.2]
      [0.0, 2.1, 1.2]
  ]
```
Example 2:
```
  data = [[1.0, 2.0, 3.0, 4.0, 5.0]]
  indices = [[1, 3]]
  updates = [[1.1, 2.1]]
  axis = 1
  output = [[1.0, 1.1, 3.0, 2.1, 5.0]]
```

�
data
indices
updatesoutput	ScatterND"	ScatterND*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
indices-typesJint64�*�
updates-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
ScatterND takes three inputs `data` tensor of rank r >= 1, `indices` tensor of rank q >= 1,
and `updates` tensor of rank q + r - indices.shape[-1] - 1. The output of the operation
is produced by creating a copy of the input `data`, and then updating its value to values
specified by `updates` at specific index positions specified by `indices`. Its output shape
is the same as the shape of `data`. Note that `indices` should not have duplicate entries.
That is, two or more `updates` for the same index-location is not supported.

`indices` is an integer tensor. Let k denote indices.shape[-1], the last dimension in the shape of `indices`.
 `indices` is treated as a (q-1)-dimensional tensor of k-tuples, where each k-tuple is a partial-index into `data`.
Hence, k can be a value at most the rank of `data`. When k equals rank(data), each update entry specifies an
update to a single element of the tensor. When k is less than rank(data) each update entry specifies an
update to a slice of the tensor.

`updates` is treated as a (q-1)-dimensional tensor of replacement-slice-values. Thus, the
first (q-1) dimensions of updates.shape must match the first (q-1) dimensions of indices.shape.
The remaining dimensions of `updates` correspond to the dimensions of the
replacement-slice-values. Each replacement-slice-value is a (r-k) dimensional tensor,
corresponding to the trailing (r-k) dimensions of `data`.  Thus, the shape of `updates`
must equal indices.shape[0:q-1] ++ data.shape[k:r-1], where ++ denotes the concatenation
of shapes.

The `output` is calculated via the following equation:

    output = np.copy(data)
    update_indices = indices.shape[:-1]
    for idx in np.ndindex(update_indices):
        output[indices[idx]] = updates[idx]

The order of iteration in the above loop is not specified.
In particular, indices should not have duplicate entries: that is, if idx1 != idx2, then indices[idx1] != indices[idx2].
This ensures that the output value does not depend on the iteration order.

This operator is the inverse of GatherND.

Example 1:
```
  data    = [1, 2, 3, 4, 5, 6, 7, 8]
  indices = [[4], [3], [1], [7]]
  updates = [9, 10, 11, 12]
  output  = [1, 11, 3, 10, 9, 6, 7, 12]
```

Example 2:
```
  data    = [[[1, 2, 3, 4], [5, 6, 7, 8], [8, 7, 6, 5], [4, 3, 2, 1]],
             [[1, 2, 3, 4], [5, 6, 7, 8], [8, 7, 6, 5], [4, 3, 2, 1]],
             [[8, 7, 6, 5], [4, 3, 2, 1], [1, 2, 3, 4], [5, 6, 7, 8]],
             [[8, 7, 6, 5], [4, 3, 2, 1], [1, 2, 3, 4], [5, 6, 7, 8]]]
  indices = [[0], [2]]
  updates = [[[5, 5, 5, 5], [6, 6, 6, 6], [7, 7, 7, 7], [8, 8, 8, 8]],
             [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3], [4, 4, 4, 4]]]
  output  = [[[5, 5, 5, 5], [6, 6, 6, 6], [7, 7, 7, 7], [8, 8, 8, 8]],
             [[1, 2, 3, 4], [5, 6, 7, 8], [8, 7, 6, 5], [4, 3, 2, 1]],
             [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3], [4, 4, 4, 4]],
             [[8, 7, 6, 5], [4, 3, 2, 1], [1, 2, 3, 4], [5, 6, 7, 8]]]
```

�
XYSelu"Selu*
alpha}-�?�*
gamma_}�?�*$
X-typesJfloatJfloat16Jdouble�2�
Selu takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the scaled exponential linear unit function,
`y = gamma * (alpha * e^x - alpha) for x <= 0`, `y = gamma * x for x > 0`,
is applied to the tensor elementwise.

�
input_sequence
positiontensor
SequenceAt"
SequenceAt*�
input_sequence-typesJ
seq(uint32J
seq(stringJseq(boolJseq(int8Jseq(float16J	seq(uint8J	seq(floatJ	seq(int64J
seq(uint64Jseq(complex64J
seq(doubleJ	seq(int32J
seq(uint16Jseq(complex128J	seq(int16�*!
position-typesJint32Jint64�2�
Outputs a tensor copy from the tensor at 'position' in 'input_sequence'.
Accepted range for 'position' is in `[-n, n - 1]`, where `n` is the number of tensors in 'input_sequence'.
Negative value means counting positions from the back.

�
inputsoutput_sequenceSequenceConstruct"SequenceConstruct*�
inputs-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2p
Construct a tensor sequence containing 'inputs' tensors.
All tensors in 'inputs' must have the same data type.

qoutputSequenceEmpty"SequenceEmpty*
dtype" �2;
Construct an empty tensor sequence, with given data type.

�
input_sequence
positionoutput_sequenceSequenceErase"SequenceErase*�
input_sequence-typesJ
seq(uint32J
seq(stringJseq(boolJseq(int8Jseq(float16J	seq(uint8J	seq(floatJ	seq(int64J
seq(uint64Jseq(complex64J
seq(doubleJ	seq(int32J
seq(uint16Jseq(complex128J	seq(int16�*!
position-typesJint32Jint64�2�
Outputs a tensor sequence that removes the tensor at 'position' from 'input_sequence'.
Accepted range for 'position' is in `[-n, n - 1]`, where `n` is the number of tensors in 'input_sequence'.
Negative value means counting positions from the back.
'position' is optional, by default it erases the last tensor from 'input_sequence'.

�
input_sequence
tensor
positionoutput_sequenceSequenceInsert"SequenceInsert*�
input_sequence-typesJ
seq(uint32J
seq(stringJseq(boolJseq(int8Jseq(float16J	seq(uint8J	seq(floatJ	seq(int64J
seq(uint64Jseq(complex64J
seq(doubleJ	seq(int32J
seq(uint16Jseq(complex128J	seq(int16�*�
tensor-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*!
position-typesJint32Jint64�2�
Outputs a tensor sequence that inserts 'tensor' into 'input_sequence' at 'position'.
'tensor' must have the same data type as 'input_sequence'.
Accepted range for 'position' is in `[-n, n]`, where `n` is the number of tensors in 'input_sequence'.
Negative value means counting positions from the back.
'position' is optional, by default it inserts 'tensor' to the back of 'input_sequence'.

�
input_sequencelengthSequenceLength"SequenceLength*�
input_sequence-typesJ
seq(uint32J
seq(stringJseq(boolJseq(int8Jseq(float16J	seq(uint8J	seq(floatJ	seq(int64J
seq(uint64Jseq(complex64J
seq(doubleJ	seq(int32J
seq(uint16Jseq(complex128J	seq(int16�2`
Produces a scalar(tensor of empty shape) containing the number of tensors in 'input_sequence'.

�
datashapeShape"Shape*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2b
Takes a tensor as input and outputs an 1D int64 tensor containing the shape of the input tensor.

�
inputoutputShrink"Shrink*
bias    �*
lambd   ?�*b
input-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Shrink takes one input data (Tensor<numeric>) and produces one Tensor output,
having same datatype and shape with input. It has two attributes, lambd and
bias. The formula of this operator is: If x < -lambd, y = x + bias;
If x > lambd, y = x - bias; Otherwise, y = 0.

�
XYSigmoid"Sigmoid*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Sigmoid takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the sigmoid function, y = 1 / (1 + exp(-x)), is applied to the
tensor elementwise.

�
inputoutputSign"Sign*l
input-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Calculate the sign of the given input tensor element-wise.
If input > 0, output 1. if input < 0, output -1. if input == 0, output 0.

�
inputoutputSin"Sin*(
input-typesJfloatJfloat16Jdouble�2>
Calculates the sine of the given input tensor, element-wise.

�
inputoutputSinh"Sinh*(
input-typesJfloatJfloat16Jdouble�2H
Calculates the hyperbolic sine of the given input tensor element-wise.

�
datasizeSize"Size*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2u
Takes a tensor as input and outputs a int64 scalar that equals to the total number of elements of the input tensor.

�
data
starts
ends
axes
stepsoutputSlice"Slice*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
starts-typesJint32Jint64�*

ends-typesJint32Jint64�*

axes-typesJint32Jint64�*
steps-typesJint32Jint64�2�

Produces a slice of the input tensor along multiple axes. Similar to numpy:
https://docs.scipy.org/doc/numpy/reference/arrays.indexing.html
Slices uses `starts`, `ends`, `axes` and `steps` inputs to specify the start and end
dimension and step for each axis in the list of axes, it uses this information to
slice the input `data` tensor. If a negative value is passed for any of the
start or end indices, it represents number of elements before the end of that
dimension. If the value passed to start or end is larger than the `n` (the
number of elements in this dimension), it represents `n`. For slicing to the
end of a dimension with unknown size, it is recommended to pass in `INT_MAX`
when sclicing forward and 'INT_MIN' when slicing backward.
If a negative value is passed for step, it represents slicing backward.
However step value cannot be 0.
If `axes` are omitted, they are set to `[0, ..., ndim-1]`.
If `steps` are omitted, they are set to `[1, ..., 1]` of length `len(starts)`
Example 1:
  data = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
  ]
  axes = [0, 1]
  starts = [1, 0]
  ends = [2, 3]
  steps = [1, 2]
  result = [
      [5, 7],
  ]
Example 2:
  data = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
  ]
  starts = [0, 1]
  ends = [-1, 1000]
  result = [
      [2, 3, 4],
  ]

�
inputoutputSoftmax"Softmax*
axis����������*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2�
The operator computes the normalized exponential values for the given input:

 Softmax(input, axis) = Exp(input) / ReduceSum(Exp(input), axis=axis, keepdims=1) 

The input does not need to explicitly be a 2D vector. The "axis" attribute
indicates the dimension along which Softmax will be performed.
The output tensor has the same shape
and contains the Softmax values of the corresponding input.

�
scores
labels
weightsoutputlog_probSoftmaxCrossEntropyLoss"SoftmaxCrossEntropyLoss*
ignore_index" �*
	reduction"mean�*3
scores-typesJfloatJfloat16Jbfloat16Jdouble�*
labels-typesJint32Jint64�*4
weights-typesJfloatJfloat16Jbfloat16Jdouble�2�Loss function that measures the softmax cross entropy
between 'scores' and 'labels'.
This operator first computes a loss tensor whose shape is identical to the labels input.
If the input is 2-D with shape (N, C), the loss tensor may be a N-element vector L = (l_1, l_2, ..., l_N).
If the input is N-D tensor with shape (N, C, D1, D2, ..., Dk),
the loss tensor L may have (N, D1, D2, ..., Dk) as its shape and L[i,][j_1][j_2]...[j_k] denotes a scalar element in L.
After L is available, this operator can optionally do a reduction operator.

shape(scores): (N, C) where C is the number of classes, or (N, C, D1, D2,..., Dk),
        with K >= 1 in case of K-dimensional loss.
shape(labels): (N) where each value is 0 <= labels[i] <= C-1, or (N, D1, D2,..., Dk),
        with K >= 1 in case of K-dimensional loss.

The loss for one sample, l_i, can caculated as follows:
    l[i][d1][d2]...[dk] = -y[i][c][d1][d2]..[dk], where i is the index of classes.
or
    l[i][d1][d2]...[dk] = -y[i][c][d1][d2]..[dk] * weights[c], if 'weights' is provided.

loss is zero for the case when label-value equals ignore_index.
    l[i][d1][d2]...[dk]  = 0, when labels[n][d1][d2]...[dk] = ignore_index

where:
    p = Softmax(scores)
    y = Log(p)
    c = labels[i][d1][d2]...[dk]

Finally, L is optionally reduced:
If reduction = 'none', the output is L with shape (N, D1, D2, ..., Dk).
If reduction = 'sum', the output is scalar: Sum(L).
If reduction = 'mean', the output is scalar: ReduceMean(L), or if weight is provided: ReduceSum(L) / ReduceSum(W),
where tensor W is of shape (N, D1, D2, ..., Dk) and W[n][d1][d2]...[dk] = weights[labels[i][d1][d2]...[dk]].

�
XYSoftplus"Softplus*$
X-typesJfloatJfloat16Jdouble�2�
Softplus takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the softplus function, y = ln(exp(x) + 1), is applied to
the tensor elementwise.

�
inputoutputSoftsign"Softsign*(
input-typesJfloatJfloat16Jdouble�2M
Calculates the softsign (x/(1+|x|)) of the given input tensor element-wise.

�
inputoutputSpaceToDepth"SpaceToDepth*
	blocksize" �*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�SpaceToDepth rearranges blocks of spatial data into depth. More specifically,
this op outputs a copy of the input tensor where values from the height and width dimensions
are moved to the depth dimension.

�
input
splitoutputsSplit"Split*
axis �*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
split-typesJint64�2�Split a tensor into a list of tensors, along the specified
'axis'. Lengths of the parts can be specified using input 'split'.
Otherwise, the tensor is split to equal sized parts.

�
input
splitoutput_sequenceSplitToSequence"SplitToSequence*
axis �*
keepdims�*�
input-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
split-typesJint32Jint64�2�Split a tensor into a sequence of tensors, along the specified
'axis'. Lengths of the parts can be specified using argument 'split'.
'split' must contain only positive numbers.
'split' is either a scalar (tensor of empty shape), or a 1-D tensor.
If 'split' is a scalar, then 'input' will be split into equally sized chunks(if possible).
Last chunk will be smaller if the 'input' size along the given axis 'axis' is not divisible
by 'split'.
Otherwise, the tensor is split into 'size(split)' chunks, with lengths of the parts on 'axis'
specified in 'split'. In this scenario, the sum of entries in 'split' must be equal to the
dimension size of input tensor on 'axis'.

�
XYSqrt"Sqrt*.
X-typesJfloatJfloat16Jbfloat16Jdouble�2�
Square root takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the square root is, y = x^0.5, is applied to
the tensor elementwise. If x is negative, then it will return NaN.

�
data
axessqueezedSqueeze"Squeeze*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*

axes-typesJint64�2�
Remove single-dimensional entries from the shape of a tensor.
Takes an input `axes` with a list of axes to squeeze.
If `axes` is not provided, all the single dimensions will be removed from
the shape. If an axis is selected with shape entry not equal to one, an error is raised.

�
XYStringNormalizer"StringNormalizer*
case_change_action"NONE�*
is_case_sensitive �*
locale" �*
	stopwords" �*
X-typesJstring�2�
StringNormalization performs string operations for basic cleaning.
This operator has only one input (denoted by X) and only one output
(denoted by Y). This operator first examines the elements in the X,
and removes elements specified in "stopwords" attribute.
After removing stop words, the intermediate result can be further lowercased,
uppercased, or just returned depending the "case_change_action" attribute.
This operator only accepts [C]- and [1, C]-tensor.
If all elements in X are dropped, the output will be the empty value of string tensor with shape [1]
if input shape is [C] and shape [1, 1] if input shape is [1, C].

�
A
BCSub"Sub*h
A-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*h
B-typesJbfloat16Jint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�2�
Performs element-wise binary subtraction (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

(Opset 14 change): Extend supported types to include uint8, int8, uint16, and int16.

�
data_0sumSum"Sum*3
data_0-typesJfloatJfloat16Jbfloat16Jdouble�2�
Element-wise sum of each of the input tensors (with Numpy-style broadcasting support).
All inputs and outputs must have the same data type.
This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
inputoutputTan"Tan*(
input-typesJfloatJfloat16Jdouble�2A
Calculates the tangent of the given input tensor, element-wise.

�
inputoutputTanh"Tanh*2
input-typesJfloatJfloat16Jbfloat16Jdouble�2K
Calculates the hyperbolic tangent of the given input tensor element-wise.

�
XYTfIdfVectorizer"TfIdfVectorizer*
max_gram_length" �*
max_skip_count" �*
min_gram_length" �*
mode" �*
ngram_counts" �*
ngram_indexes" �*
pool_int64s" �*
pool_strings" �*
weights" �*"
X-typesJint32Jint64Jstring�2�
This transform extracts n-grams from the input sequence and save them as a vector. Input can
be either a 1-D or 2-D tensor. For 1-D input, output is the n-gram representation of that input.
For 2-D input, the output is also a  2-D tensor whose i-th row is the n-gram representation of the i-th input row.
More specifically, if input shape is [C], the corresponding output shape would be [max(ngram_indexes) + 1].
If input shape is [N, C], this operator produces a [N, max(ngram_indexes) + 1]-tensor.

In contrast to standard n-gram extraction, here, the indexes of extracting an n-gram from the original
sequence are not necessarily consecutive numbers. The discontinuity between indexes are controlled by the number of skips.
If the number of skips is 2, we should skip two tokens when scanning through the original sequence.
Let's consider an example. Assume that input sequence is [94, 17, 36, 12, 28] and the number of skips is 2.
The associated 2-grams are [94, 12] and [17, 28] respectively indexed by [0, 3] and [1, 4].
If the number of skips becomes 0, the 2-grams generated are [94, 17], [17, 36], [36, 12], [12, 28]
indexed by [0, 1], [1, 2], [2, 3], [3, 4], respectively.

The output vector (denoted by Y) stores the count of each n-gram;
Y[ngram_indexes[i]] indicates the times that the i-th n-gram is found. The attribute ngram_indexes is used to determine the mapping
between index i and the corresponding n-gram's output coordinate. If pool_int64s is [94, 17, 17, 36], ngram_indexes is [1, 0],
ngram_counts=[0, 0], then the Y[0] (first element in Y) and Y[1] (second element in Y) are the counts of [17, 36] and [94, 17],
respectively. An n-gram which cannot be found in pool_strings/pool_int64s should be ignored and has no effect on the output.
Note that we may consider all skips up to S when generating the n-grams.

The examples used above are true if mode is "TF". If mode is "IDF", all the counts larger than 1 would be truncated to 1 and
the i-th element in weights would be used to scale (by multiplication) the count of the i-th n-gram in pool. If mode is "TFIDF",
this operator first computes the counts of all n-grams and then scale them by the associated values in the weights attribute.

Only one of pool_strings and pool_int64s can be set. If pool_int64s is set, the input should be an integer tensor.
If pool_strings is set, the input must be a string tensor.

�
XYThresholdedRelu"ThresholdedRelu*
alpha  �?�*$
X-typesJfloatJfloat16Jdouble�2�
ThresholdedRelu takes one input data (Tensor<T>) and produces one output data
(Tensor<T>) where the rectified linear function, y = x for x > alpha, y = 0 otherwise,
is applied to the tensor elementwise.

�
input
repeatsoutputTile"Tile*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
repeats-typesJint64�2�Constructs a tensor by tiling a given tensor.
This is the same as function `tile` in Numpy, but no broadcast.
For example A = [[1, 2], [3, 4]], B = [1, 2], tile(A, B) = [[1, 2, 1, 2], [3, 4, 3, 4]]

�
X
KValuesIndicesTopK"TopK*
axis����������*
largest�*
sorted�*^
X-typesJint8Jint16Juint16Juint64Jint32JdoubleJfloat16Juint8JfloatJint64Juint32�*
K-typesJint64�2�
Retrieve the top-K largest or smallest elements along a specified axis. Given an input tensor of
shape [a_1, a_2, ..., a_n, r] and integer argument k, return two outputs:
  -Value tensor of shape [a_1, a_2, ..., a_{axis-1}, k, a_{axis+1}, ... a_n]
    which contains the values of the top k elements along the specified axis
  -Index tensor of shape [a_1, a_2, ..., a_{axis-1}, k, a_{axis+1}, ... a_n] which
   contains the indices of the top k elements (original indices from the input
   tensor).

If "largest" is 1 (the default value) then the k largest elements are returned.
If "sorted" is 1 (the default value) then the resulting k elements will be sorted.
If "sorted" is 0, order of returned 'Values' and 'Indices' are undefined.

Given two equivalent values, this operator uses the indices along the axis as
 a tiebreaker. That is, the element with the lower index will appear first.

�
data
transposed	Transpose"	Transpose*
perm" �*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Transpose the input tensor similar to numpy.transpose. For example, when
perm=(1, 0, 2), given an input tensor of shape (1, 2, 3), the output shape
will be (2, 1, 3).

�
XYZTreeEnsembleClassifier"TreeEnsembleClassifier*
base_values" �*
	class_ids" �*
class_nodeids" �*
class_treeids" �*
class_weights" �*
classlabels_int64s" �*
classlabels_strings" �*
nodes_falsenodeids" �*
nodes_featureids" �*
nodes_hitrates" �*&
nodes_missing_value_tracks_true" �*
nodes_modes" �*
nodes_nodeids" �*
nodes_treeids" �*
nodes_truenodeids" �*
nodes_values" �*
post_transform"NONE�*)
X-typesJint32Jint64JfloatJdouble�2�
    Tree Ensemble classifier.  Returns the top class for each of N inputs.<br>
    The attributes named 'nodes_X' form a sequence of tuples, associated by
    index into the sequences, which must all be of equal length. These tuples
    define the nodes.<br>
    Similarly, all fields prefixed with 'class_' are tuples of votes at the leaves.
    A leaf may have multiple votes, where each vote is weighted by
    the associated class_weights index.<br>
    One and only one of classlabels_strings or classlabels_int64s
    will be defined. The class_ids are indices into this list.

�	
XYTreeEnsembleRegressor"TreeEnsembleRegressor*
aggregate_function"SUM�*
base_values" �*
	n_targets" �*
nodes_falsenodeids" �*
nodes_featureids" �*
nodes_hitrates" �*&
nodes_missing_value_tracks_true" �*
nodes_modes" �*
nodes_nodeids" �*
nodes_treeids" �*
nodes_truenodeids" �*
nodes_values" �*
post_transform"NONE�*

target_ids" �*
target_nodeids" �*
target_treeids" �*
target_weights" �*)
X-typesJint32Jint64JfloatJdouble�2�
    Tree Ensemble regressor.  Returns the regressed values for each input in N.<br>
    All args with nodes_ are fields of a tuple of tree nodes, and
    it is assumed they are the same length, and an index i will decode the
    tuple across these inputs.  Each node id can appear only once
    for each tree id.<br>
    All fields prefixed with target_ are tuples of votes at the leaves.<br>
    A leaf may have multiple votes, where each vote is weighted by
    the associated target_weights index.<br>
    All trees must have their node ids start at 0 and increment by 1.<br>
    Mode enum is BRANCH_LEQ, BRANCH_LT, BRANCH_GTE, BRANCH_GT, BRANCH_EQ, BRANCH_NEQ, LEAF

�

input
koutputTrilu"Trilu*
upper�*�
input-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
k-typesJint64�2�
Given a 2-D matrix or batches of 2-D matrices, returns the upper or lower triangular part of the tensor(s).
The attribute "upper" determines whether the upper or lower part is retained. If set to true,
the upper triangular matrix is retained. Lower triangular matrix is retained otherwise.
Default value for the "upper" attribute is true.
Trilu takes one input tensor of shape [*, N, M], where * is zero or more batch dimensions. The upper triangular part consists
of the elements on and above the given diagonal (k). The lower triangular part consists of elements on and below the diagonal.
All other elements in the matrix are set to zero.
If k = 0, the triangular part on and above/below the main diagonal is retained.
If upper is set to true, a positive k retains the upper triangular matrix excluding the main diagonal and (k-1) diagonals above it.
A negative k value retains the main diagonal and |k| diagonals below it.
If upper is set to false, a positive k retains the lower triangular matrix including the main diagonal and k diagonals above it.
A negative k value excludes the main diagonal and (|k|-1) diagonals below it.

�
XYindicesinverse_indicescountsUnique"Unique*
axis" �*
sorted�*�
X-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
Find the unique elements of a tensor. When an optional attribute 'axis' is provided, unique subtensors sliced along the 'axis' are returned.
Otherwise the input tensor is flattened and unique values of the flattened tensor are returned.

This operator returns the unique values or sliced unique subtensors of the input tensor and three optional outputs.
The first output tensor 'Y' contains all unique values or subtensors of the input.
The second optional output tensor 'indices' contains indices of 'Y' elements' first occurance in 'X'..
The third optional output tensor 'inverse_indices' contains, for elements of 'X', its corresponding indices in 'Y'. ".
The fourth optional output tensor 'counts' contains the count of each element of 'Y' in the input.

Outputs are either sorted in ascending order or optionally in the order of the first occurrence of the values in the input.

https://docs.scipy.org/doc/numpy/reference/generated/numpy.unique.html

Example 1:
  input_X = [2, 1, 1, 3, 4, 3]
  attribute_sorted = 0
  attribute_axis = None
  output_Y = [2, 1, 3, 4]
  output_indices = [0, 1, 3, 4]
  output_inverse_indices = [0, 1, 1, 2, 3, 2]
  output_counts = [1, 2, 2, 1]

Example 2:
  input_X = [[1, 3], [2, 3]]
  attribute_sorted = 1
  attribute_axis = None
  output_Y = [1, 2, 3]
  output_indices = [0, 2, 1]
  output_inverse_indices = [0, 2, 1, 2]
  output_counts = [1, 1, 2]

Example 3:
  input_X = [[1, 0, 0], [1, 0, 0], [2, 3, 4]]
  attribute_sorted = 1
  attribute_axis = 0
  output_Y = [[1, 0, 0], [2, 3, 4]]
  output_indices = [0, 2]
  output_inverse_indices = [0, 0, 1]
  output_counts = [2, 1]

Example 4:
  input_x = [[[1., 1.], [0., 1.], [2., 1.], [0., 1.]],
             [[1., 1.], [0., 1.], [2., 1.], [0., 1.]]]
  attribute_sorted = 1
  attribute_axis = 1

  intermediate data are presented below for better understanding:

  there are 4 subtensors sliced along axis 1 of input_x (shape = (2, 4, 2)):
  A: [[1, 1], [1, 1]],
     [[0, 1], [0, 1]],
     [[2, 1], [2, 1]],
     [[0, 1], [0, 1]].

  there are 3 unique subtensors:
  [[1, 1], [1, 1]],
  [[0, 1], [0, 1]],
  [[2, 1], [2, 1]].

  sorted unique subtensors:
  B: [[0, 1], [0, 1]],
     [[1, 1], [1, 1]],
     [[2, 1], [2, 1]].

  output_Y is constructed from B:
  [[[0. 1.], [1. 1.], [2. 1.]],
   [[0. 1.], [1. 1.], [2. 1.]]]

  output_indices is to map from B to A:
  [1, 0, 2]

  output_inverse_indices is to map from A to B:
  [1, 0, 2, 0]

  output_counts = [2 1 1]

�
data
axesexpanded	Unsqueeze"	Unsqueeze*�

data-typesJbfloat16Jint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*

axes-typesJint64�2�
Insert single-dimensional entries to the shape of an input tensor (`data`).
Takes one required input `axes` - which contains a list of dimension indices and this operator will insert a dimension of value `1` into the corresponding index of the output tensor (`expanded`).

For example:
  Given an input tensor (`data`) of shape [3, 4, 5], then
  Unsqueeze(data, axes=[0, 4]) outputs a tensor (`expanded`) containing same data as `data` but with shape [1, 3, 4, 5, 1].

The input `axes` should not contain any duplicate entries. It is an error if it contains duplicates.
The rank of the output tensor (`output_rank`) is the rank of the input tensor (`data`) plus the number of values in `axes`.
Each value in `axes` should be within the (inclusive) range [-output_rank , output_rank - 1].
The order of values in `axes` does not matter and can come in any order.


�
X
scalesYUpsample"Upsample*
mode"nearest�*�
X-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*
scales-typesJfloat�2
Upsample the input tensor.
Each dimension value of the output tensor is:
  output_dimension = floor(input_dimension * scale).

�
	condition
X
YoutputWhere"Where*
condition-typesJbool�*�
X-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�*�
Y-typesJint16Juint16Jint8Juint64Jint32JboolJ
complex128JdoubleJfloat16J	complex64Juint8JfloatJint64Juint32Jstring�2�
    Return elements, either from X or Y, depending on condition
    (with Numpy-style broadcasting support).
    Where behaves like numpy.where with three parameters:
    https://docs.scipy.org/doc/numpy/reference/generated/numpy.where.html

�
A
BCXor"Xor*
A-typesJbool�*
B-typesJbool�2�
Returns the tensor resulted from performing the `xor` logical operation
elementwise on the input tensors `A` and `B` (with Numpy-style broadcasting support).

This operator supports **multidirectional (i.e., Numpy-style) broadcasting**; for more details please check [the doc](Broadcasting.md).

�
XZZipMap"ZipMap*
classlabels_int64s" �*
classlabels_strings" �*
X-typesJfloat�2�
    Creates a map from the input and the attributes.<br>
    The values are provided by the input tensor, while the keys are specified by the attributes.
    Must provide keys in either classlabels_strings or classlabels_int64s (but not both).<br>
    The columns of the tensor correspond one-by-one to the keys specified by the attributes. There must be as many columns as keys.<br>
