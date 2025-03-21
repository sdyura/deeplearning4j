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

package org.nd4j.interceptor.advice;

import net.bytebuddy.asm.Advice;
import org.nd4j.interceptor.util.InterceptorUtils;
import org.nd4j.linalg.api.ops.CustomOp;

public class CustomOpAdvice {
    @Advice.OnMethodExit
    public static void exit(@Advice.AllArguments Object[] args) {
        if (args != null && args.length > 0) {
            Object opOrCustomOp = args[0];
            CustomOp customOp = (CustomOp) opOrCustomOp;
            InterceptorUtils.logCustomOpExecution(customOp);
        }
    }
}
