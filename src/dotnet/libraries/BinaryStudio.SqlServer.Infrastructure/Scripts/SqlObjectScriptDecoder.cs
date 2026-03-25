using System;
using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlObjectScriptDecoder
        {
        #region M:Decode(String):IList<SqlScriptBatch>
        public IList<SqlScriptBatch> Decode(String script) {
            (new SqlScriptParser()).Parse(script,out var batches);
            if (batches.Count > 0) {
                return batches;
                }
            return Array.Empty<SqlScriptBatch>();
            }
        #endregion
        }
    }