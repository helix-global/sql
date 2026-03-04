using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDefaultConstraint : SqlScriptConstraint<SqlDefaultConstraint>
        {
        #region ctor{IServiceProvider,SqlDefaultConstraint}
        public SqlScriptDefaultConstraint(IServiceProvider context,SqlDefaultConstraint source)
            : base(context,source)
            {
            }
        #endregion
        }
    }