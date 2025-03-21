/*
 *  ******************************************************************************
 *  *
 *  *
 *  * This program and the accompanying materials are made available under the
 *  * terms of the Apache License, Version 2.0 which is available at
 *  * https://www.apache.org/licenses/LICENSE-2.0.
 *  *
 *  *  See the NOTICE file distributed with this work for additional
 *  *  information regarding copyright ownership.
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  * License for the specific language governing permissions and limitations
 *  * under the License.
 *  *
 *  * SPDX-License-Identifier: Apache-2.0
 *  *****************************************************************************
 */

package org.nd4j.linalg.jcublas.buffer;

import org.bytedeco.javacpp.Pointer;
import org.bytedeco.javacpp.indexer.Indexer;
import org.nd4j.linalg.api.buffer.DataBuffer;
import org.nd4j.linalg.api.buffer.DataType;
import org.nd4j.linalg.api.memory.MemoryWorkspace;
import org.nd4j.common.util.ArrayUtil;

import java.nio.ByteBuffer;

/**
 * Cuda Short buffer
 *
 * @author raver119@gmail.com
 */
public class CudaUInt64DataBuffer extends BaseCudaDataBuffer {
    /**
     * Meant for creating another view of a buffer
     *
     * @param pointer the underlying buffer to create a view from
     * @param indexer the indexer for the pointer
     * @param length  the length of the view
     */
    public CudaUInt64DataBuffer(Pointer pointer, Indexer indexer, long length) {
        super(pointer, indexer, length);
    }

    public CudaUInt64DataBuffer(ByteBuffer buffer, DataType dataType, long length, long offset) {
        super(buffer, dataType, length, offset);
    }

    /**
     * Base constructor
     *
     * @param length the length of the buffer
     */
    public CudaUInt64DataBuffer(long length) {
        super(length, 8);
    }

    public CudaUInt64DataBuffer(long length, boolean initialize) {
        super(length, 8, initialize);
    }

    public CudaUInt64DataBuffer(long length, int elementSize) {
        super(length, elementSize);
    }


    public CudaUInt64DataBuffer(long length, boolean initialize, MemoryWorkspace workspace) {
        super(length, 8, initialize, workspace);
    }

    public CudaUInt64DataBuffer(ByteBuffer underlyingBuffer, DataType dataType, long length) {
        super(underlyingBuffer, dataType, length);
    }


    /**
     * Initialize the opType of this buffer
     */
    @Override
    protected void initTypeAndSize() {
        elementSize = 8;
        type = DataType.UINT64;
    }



    public CudaUInt64DataBuffer(float[] buffer) {
        super(buffer);
    }



    public CudaUInt64DataBuffer(Pointer pointer, Pointer specialPointer, Indexer indexer, long length){
        super(pointer, specialPointer, indexer, length);
    }

    public CudaUInt64DataBuffer(double[] data) {
        this(data.length);
        setData(data);
    }


    public CudaUInt64DataBuffer(int[] data) {
        this(data.length);
        setData(data);
    }


    @Override
    public void assign(long[] indices, double[] data, boolean contiguous, long inc) {

        if (indices.length != data.length)
            throw new IllegalArgumentException("Indices and data length must be the same");
        if (indices.length > length())
            throw new IllegalArgumentException("More elements than space to assign. This buffer is of length "
                            + length() + " where the indices are of length " + data.length);

        if (contiguous) {
            /*long offset = indices[0];
            Pointer p = Pointer.to(data);
            set(offset, data.length, p, inc);
            */
            throw new UnsupportedOperationException();
        } else
            throw new UnsupportedOperationException("Only contiguous supported");
    }

    @Override
    protected DataBuffer create(long length) {
        return new CudaUInt64DataBuffer(length);
    }


    @Override
    public float[] getFloatsAt(long offset, long inc, int length) {
        return super.getFloatsAt(offset, inc, length);
    }

    @Override
    public double[] getDoublesAt(long offset, long inc, int length) {
        return ArrayUtil.toDoubles(getFloatsAt(offset, inc, length));
    }



    @Override
    public void setData(float[] data) {
        setData(ArrayUtil.toShorts(data));
    }

    @Override
    public void setData(int[] data) {
        setData(ArrayUtil.toShorts(data));
    }



    @Override
    public void setData(double[] data) {
        setData(ArrayUtil.toFloats(data));
    }

    @Override
    public DataType dataType() {
        return DataType.UINT64;
    }

    @Override
    public float[] asFloat() {
        return super.asFloat();
    }

    @Override
    public double[] asDouble() {
        return ArrayUtil.toDoubles(asFloat());
    }

    @Override
    public int[] asInt() {
        return ArrayUtil.toInts(asFloat());
    }


    @Override
    public double getDouble(long i) {
        return super.getFloat(i);
    }


    @Override
    public DataBuffer create(double[] data) {
        return new CudaUInt64DataBuffer(data);
    }

    @Override
    public DataBuffer create(float[] data) {
        return new CudaUInt64DataBuffer(data);
    }

    @Override
    public DataBuffer create(int[] data) {
        return new CudaUInt64DataBuffer(data);
    }

    @Override
    public void flush() {

    }



}
