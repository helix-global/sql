using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlBatch))]
    internal sealed class SqlScriptBatch : SqlScriptCodeObject<SqlBatch>
        {
        #region ctor{IServiceProvider,SqlBatch}
        public SqlScriptBatch(IServiceProvider context,SqlBatch source)
            : base(context,source)
            {
            }
        #endregion
        }
    }