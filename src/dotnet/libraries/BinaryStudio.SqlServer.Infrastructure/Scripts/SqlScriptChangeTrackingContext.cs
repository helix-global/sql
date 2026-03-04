using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptChangeTrackingContext : SqlScriptCodeObject<SqlChangeTrackingContext>
        {
        #region ctor{IServiceProvider,SqlChangeTrackingContext}
        public SqlScriptChangeTrackingContext(IServiceProvider context,SqlChangeTrackingContext source)
            : base(context,source)
            {
            }
        #endregion
        }
    }