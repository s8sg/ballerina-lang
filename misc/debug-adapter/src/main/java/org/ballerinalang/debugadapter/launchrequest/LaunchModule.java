/*
 * Copyright (c) 2019, WSO2 Inc. (http://wso2.com) All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


package org.ballerinalang.debugadapter.launchrequest;

import org.ballerinalang.debugadapter.PackageUtils;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;

/**
 * Launches a ballerina module.
 */
public class LaunchModule extends LauncherImpl implements Launch {

    private final Map<String, Object> args;

    LaunchModule(Map<String, Object> args) {
        super(args);
        this.args = args;
    }

    @Override
    public Process start() {
        ProcessBuilder processBuilder = new ProcessBuilder();
        String balFile = args.get("script").toString();
        processBuilder.command(getLauncherCommand(PackageUtils.getModuleName(balFile)));

        Path projectRoot = PackageUtils.findProjectRoot(Paths.get(balFile));

        processBuilder.directory(projectRoot.toFile());
        try {
            return processBuilder.start();
        } catch (IOException e) {
            return null;
        }
    }
}
