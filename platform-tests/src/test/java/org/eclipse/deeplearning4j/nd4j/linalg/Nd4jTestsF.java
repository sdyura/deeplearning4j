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

package org.eclipse.deeplearning4j.nd4j.linalg;

import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import org.nd4j.common.tests.tags.NativeTag;
import org.nd4j.linalg.BaseNd4jTestWithBackends;
import org.nd4j.linalg.api.buffer.DataType;
import org.nd4j.linalg.api.ndarray.INDArray;
import org.nd4j.linalg.factory.Nd4j;
import org.nd4j.linalg.factory.Nd4jBackend;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;

@Slf4j
@NativeTag
public class Nd4jTestsF extends BaseNd4jTestWithBackends {

    DataType initialType = Nd4j.dataType();

    @ParameterizedTest
    @MethodSource("org.nd4j.linalg.BaseNd4jTestWithBackends#configs")
    public void testConcat3D_Vstack_F(Nd4jBackend backend) {
        int[] shape = new int[] {1, 1000, 150};


        List<INDArray> cArrays = new ArrayList<>();
        List<INDArray> fArrays = new ArrayList<>();

        for (int e = 0; e < 32; e++) {
            cArrays.add(Nd4j.create(shape, 'f').assign(e));
        }

        Nd4j.getExecutioner().commit();

        long time1 = System.currentTimeMillis();
        INDArray res = Nd4j.vstack(cArrays);
        long time2 = System.currentTimeMillis();

        log.info("Time spent: {} ms", time2 - time1);

        for (int e = 0; e < 32; e++) {
            INDArray tad = res.tensorAlongDimension(e, 1, 2);
            assertEquals((double) e, tad.meanNumber().doubleValue(), 1e-5);
        }
    }


    @ParameterizedTest
    @MethodSource("org.nd4j.linalg.BaseNd4jTestWithBackends#configs")
    public void testSlice_1(Nd4jBackend backend) {
        val arr = Nd4j.linspace(1,4, 4, DataType.DOUBLE).reshape(2, 2, 1);
        val exp0 = Nd4j.create(new double[]{1, 3}, new int[] {2, 1});
        val exp1 = Nd4j.create(new double[]{2, 4}, new int[] {2, 1});

        val slice0 = arr.slice(0).dup('f');
        assertEquals(exp0, slice0);
        assertEquals(exp0, arr.slice(0));

        val slice1 = arr.slice(1).dup('f');
        assertEquals(exp1, slice1);
        assertEquals(exp1, arr.slice(1));
    }

    @Override
    public char ordering() {
        return 'f';
    }
}
