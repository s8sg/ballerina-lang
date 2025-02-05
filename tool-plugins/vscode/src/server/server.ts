'use strict';
/**
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
import * as path from 'path';
import { log } from '../utils/logger';
import { ServerOptions, ExecutableOptions } from 'vscode-languageclient';

export function getServerOptions(ballerinaHome: string, experimental: boolean, debugLogsEnabled: boolean) : ServerOptions {
    log(`Using Ballerina installation at ${ballerinaHome} for Language server.`);

    let cmd;
    const cwd = path.join(ballerinaHome, 'lib', 'tools', 'lang-server', 'launcher');
    let args = [];
    if (process.platform === 'win32') {
        cmd = path.join(cwd, 'language-server-launcher.bat');
    } else {
        cmd = 'sh';
        args.push(path.join(cwd, 'language-server-launcher.sh'));
    }

    let opt: ExecutableOptions = {cwd: cwd};
    opt.env = Object.assign({}, process.env);
    if (process.env.LSDEBUG === "true") {
        log('Language Server is starting in debug mode.');
        args.push('--debug');
    }
    if (debugLogsEnabled) {
        log('Language Server debug logs enabled.');
        opt.env.DEBUG_LOG = debugLogsEnabled;
    }
    if (process.env.LS_CUSTOM_CLASSPATH) {
        args.push('--classpath', process.env.LS_CUSTOM_CLASSPATH);
    }
    if (experimental) {
        args.push('--experimental');
    }

    return {
        command: cmd,
        args,
        options: opt
    };
}