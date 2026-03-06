using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.SqlServer.Management.SqlParser.Parser;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptParser
        {
        #region M:Parse(IServiceProvider,String,{out}IList<SqlScriptBatch>)
        public void Parse(IServiceProvider service,String script,out IList<SqlScriptBatch> batches) {
            batches = Array.Empty<SqlScriptBatch>();
            if (!String.IsNullOrWhiteSpace(script)) {
                var ParserResult = Parser.Parse(script);
                if (ParserResult != null) {
                    batches = ParserResult.Script.Batches
                        .Select(i=>new SqlScriptBatch(service,i))
                        .AsReadOnly();
                    }
                }
            }
        #endregion
        #region M:Parse(String,{out}IList<SqlScriptBatch>)
        public void Parse(String script,out IList<SqlScriptBatch> batches) {
            Parse(null,script,out batches);
            }
        #endregion
        }
    }
