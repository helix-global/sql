using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptInlineIndexConstraint : SqlScriptConstraint<SqlInlineIndexConstraint>
        {
        #region ctor{IServiceProvider,SqlInlineIndexConstraint}
        public SqlScriptInlineIndexConstraint(IServiceProvider context,SqlInlineIndexConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }