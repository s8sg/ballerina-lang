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

package org.ballerinalang.debugadapter;


import org.ballerinalang.toml.model.Manifest;
import org.wso2.ballerinalang.util.TomlParserUtils;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Package Utils.
 */
public class PackageUtils {
    public static final String MANIFEST_FILE_NAME = "Ballerina.toml";
    /**
     * Find the project root by recursively up to the root.
     *
     * @param projectDir project path
     * @return project root
     */
    public static Path findProjectRoot(Path projectDir) {
        Path path = projectDir.resolve(MANIFEST_FILE_NAME);
        if (Files.exists(path)) {
            return projectDir;
        }
        Path parentsParent = projectDir.getParent();
        if (null != parentsParent) {
            return findProjectRoot(parentsParent);
        }
        return null;
    }

    /**
     * Get the relative file path to a bal file from its project root.
     * @param balFilePath absolute path to bal file
     * @return relative path from project root
     */
    public static String getRelativeFilePath(String balFilePath) {
        Path path = Paths.get(balFilePath);
        Path projectRoot = findProjectRoot(path);
        Path relativePath = projectRoot.relativize(path);

        String packagePath = relativePath.toString();
        Manifest manifest = TomlParserUtils.getManifest(projectRoot);
        String orgName = manifest.getProject().getOrgName();
        if (packagePath.startsWith("src")) {
            packagePath = packagePath.replaceFirst("src", orgName);
        }
        return packagePath.replace(File.separator, ".");
    }

    public static String getModuleName(String balFilePath) {
        Path path = Paths.get(balFilePath);
        Path projectRoot = findProjectRoot(path);
        Path relativePath = projectRoot.relativize(path);

        String packagePath = relativePath.toString();
        String fileSeparatorChar = File.separatorChar == '\\' ? "\\\\" : File.separator;
        if (packagePath.startsWith("src")) {
            packagePath = packagePath.replaceFirst("src" + fileSeparatorChar, "");
        }
        return packagePath.split(fileSeparatorChar)[0];
    }
}
