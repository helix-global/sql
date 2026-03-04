using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptIndexHint : SqlScriptHint<SqlIndexHint>
        {
        #region ctor{IServiceProvider,SqlIndexHint}
        public SqlScriptIndexHint(IServiceProvider context,SqlIndexHint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }