/*
 * Copyright 2008 Netflix, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package net.oauth.client;

import java.io.IOException;
import java.util.Map;
import net.oauth.OAuth;
import net.oauth.OAuthMessageFromHttp;
import net.oauth.http.HttpResponseMessage;

/**
 * An HTTP response, encapsulated as an OAuthMessage.
 * 
 * @author John Kristian
 */
public final class OAuthResponseMessage extends OAuthMessageFromHttp
{
    protected OAuthResponseMessage(HttpResponseMessage http) throws IOException
    {
        super(http);
        for (Map.Entry<String, String> header : http.headers) {
            if ("WWW-Authenticate".equalsIgnoreCase(header.getKey())) {
                for (OAuth.Parameter parameter : decodeAuthorization(header.getValue())) {
                    if (!"realm".equalsIgnoreCase(parameter.getKey())) {
                        addParameter(parameter);
                    }
                }
            }
        }
    }

    @Override
    protected void completeParameters() throws IOException
    {
        super.completeParameters();
        String body = readBodyAsString();
        if (body != null) {
            addParameters(OAuth.decodeForm(body.trim()));
        }
    }
}
