using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptErrorCodeObject : SqlScriptCodeObject<SqlErrorCodeObject>
        {
        #region ctor{IServiceProvider,SqlErrorCodeObject}
        public SqlScriptErrorCodeObject(IServiceProvider context,SqlErrorCodeObject source)
            : base(context,source)
            {
            }
        #endregion
        }
    }