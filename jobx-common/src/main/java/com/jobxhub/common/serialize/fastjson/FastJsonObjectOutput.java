/**
 * Copyright (c) 2015 The JobX Project
 * <p>
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package com.jobxhub.common.serialize.fastjson;

import com.alibaba.fastjson.serializer.JSONSerializer;
import com.alibaba.fastjson.serializer.SerializeWriter;
import com.alibaba.fastjson.serializer.SerializerFeature;
import com.jobxhub.common.serialize.ObjectOutput;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.io.Writer;

/**
 * JsonObjectOutput
 */
public class FastJsonObjectOutput implements ObjectOutput {

    private final PrintWriter writer;

    public FastJsonObjectOutput(OutputStream out) {
        this(new OutputStreamWriter(out));
    }

    public FastJsonObjectOutput(Writer writer) {
        this.writer = new PrintWriter(writer);
    }

    public void writeBool(boolean v) throws IOException {
        writeObject(v);
    }

    public void writeByte(byte v) throws IOException {
        writeObject(v);
    }

    public void writeShort(short v) throws IOException {
        writeObject(v);
    }

    public void writeInt(int v) throws IOException {
        writeObject(v);
    }

    public void writeLong(long v) throws IOException {
        writeObject(v);
    }

    public void writeFloat(float v) throws IOException {
        writeObject(v);
    }

    public void writeDouble(double v) throws IOException {
        writeObject(v);
    }

    public void writeUTF(String v) throws IOException {
        writeObject(v);
    }

    public void writeBytes(byte[] b) throws IOException {
        writer.println(new String(b));
    }

    public void writeBytes(byte[] b, int off, int len) throws IOException {
        writer.println(new String(b, off, len));
    }

    public void writeObject(Object obj) throws IOException {
        SerializeWriter out = new SerializeWriter();
        JSONSerializer serializer = new JSONSerializer(out);
        serializer.config(SerializerFeature.WriteEnumUsingToString, true);
        serializer.write(obj);
        out.writeTo(writer);
        out.close(); // for reuse SerializeWriter buf
        writer.println();
        writer.flush();
    }

    public void flushBuffer() throws IOException {
        writer.flush();
    }

}