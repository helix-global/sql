using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    internal abstract class SqlObjectScriptDecoder
        {
        public void Decode(String script) {
            (new SqlScriptParser()).Parse(script,out var batches);
            if (batches.Count > 0) {
                return;
                }
            }
        }
    }