package org.opencron.rpc;

public interface Server {

    boolean isBound();

    void open();

    void close() throws Throwable;

}