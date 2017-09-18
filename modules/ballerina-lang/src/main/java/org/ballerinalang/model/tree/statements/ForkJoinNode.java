/*
*  Copyright (c) 2017, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
*
*  WSO2 Inc. licenses this file to you under the Apache License,
*  Version 2.0 (the "License"); you may not use this file except
*  in compliance with the License.
*  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing,
*  software distributed under the License is distributed on an
*  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*  KIND, either express or implied.  See the License for the
*  specific language governing permissions and limitations
*  under the License.
*/
package org.ballerinalang.model.tree.statements;

import org.ballerinalang.model.tree.IdentifierNode;
import org.ballerinalang.model.tree.VariableNode;
import org.ballerinalang.model.tree.WorkerNode;
import org.ballerinalang.model.tree.expressions.ExpressionNode;
import org.ballerinalang.model.tree.types.TypeNode;

import java.util.List;

/**
 * @since 0.94
 */
public interface ForkJoinNode extends StatementNode {

    List<? extends WorkerNode> getWorkers();

    List<? extends IdentifierNode> getJoinedWorkerIdentifiers();

    JoinType getJoinType();

    int getJoinCount();

    BlockNode getJoinBody();

    ExpressionNode getTimeOutExpression();

    VariableNode getTimeOutVariable();

    BlockNode getTimeoutBody();
    
    VariableNode getJoinResultVar();
        
    void setJoinResultVar(VariableNode var);
    
    /**
     * Join type.
     */
    enum JoinType {
        SOME,
        ALL
    }
}
