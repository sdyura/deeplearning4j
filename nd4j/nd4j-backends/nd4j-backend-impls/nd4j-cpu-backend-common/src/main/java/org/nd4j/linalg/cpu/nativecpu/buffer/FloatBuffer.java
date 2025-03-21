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

package org.nd4j.linalg.cpu.nativecpu.buffer;


import org.bytedeco.javacpp.Pointer;
import org.bytedeco.javacpp.indexer.Indexer;
import org.nd4j.linalg.api.buffer.DataBuffer;
import org.nd4j.linalg.api.buffer.DataType;
import org.nd4j.linalg.api.memory.MemoryWorkspace;

import java.nio.ByteBuffer;

/**
 * Data buffer for floats
 *
 * @author Adam Gibson
 */
public class FloatBuffer extends BaseCpuDataBuffer {

    /**
     * Meant for creating another view of a buffer
     *
     * @param pointer the underlying buffer to create a view from
     * @param indexer the indexer for the pointer
     * @param length  the length of the view
     */
    public FloatBuffer(Pointer pointer, Indexer indexer, long length) {
        super(pointer, indexer, length);
    }

    /**
     * Create a float buffer with the given length
     * @param length the float buffer with the given length
     */
    public FloatBuffer(long length) {
        super(length);

    }



    public FloatBuffer(long length, boolean initialize) {
        super(length, initialize);
    }

    public FloatBuffer(long length, boolean initialize, MemoryWorkspace workspace) {
        super(length, initialize, workspace);
    }

    public FloatBuffer(int length, int elementSize) {
        super(length, elementSize);
    }

    public FloatBuffer(int length, int elementSize, long offset) {
        super(length, elementSize);
    }

    public FloatBuffer(ByteBuffer underlyingBuffer, DataType dataType, long length) {
        super(underlyingBuffer, dataType, length);
    }

    /**
     * Initialize the opType of this buffer
     */
    @Override
    protected void initTypeAndSize() {
        type = DataType.FLOAT;
        elementSize = 4;
    }



    public FloatBuffer(float[] data) {
        this(data, true);
    }

    public FloatBuffer(float[] data, MemoryWorkspace workspace) {
        this(data, true, workspace);
    }

    public FloatBuffer(int[] data) {
        this(data, true);
    }

    public FloatBuffer(double[] data) {
        this(data, true);
    }

    public FloatBuffer(int[] data, boolean copyOnOps) {
        super(data, copyOnOps);
    }


    public FloatBuffer(double[] data, boolean copyOnOps) {
        super(data, copyOnOps);
    }


    public FloatBuffer(float[] floats, boolean copy) {
        super(floats, copy);
    }

    public FloatBuffer(float[] floats, boolean copy, MemoryWorkspace workspace) {
        super(floats, copy, workspace);
    }

    public FloatBuffer(float[] data, boolean copy, long offset) {
        super(data, copy);
    }

    public FloatBuffer(float[] data, boolean copy, long offset, MemoryWorkspace workspace) {
        super(data, copy, workspace);
    }

    @Override
    protected DataBuffer create(long length) {
        return new FloatBuffer(length);
    }


    @Override
    public DataBuffer create(double[] data) {
        return new FloatBuffer(data);
    }

    @Override
    public DataBuffer create(float[] data) {
        return new FloatBuffer(data);
    }

    @Override
    public DataBuffer create(int[] data) {
        return new FloatBuffer(data);
    }


}
