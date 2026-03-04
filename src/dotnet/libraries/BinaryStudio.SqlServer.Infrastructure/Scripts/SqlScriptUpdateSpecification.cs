using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptUpdateSpecification : SqlScriptUpdateDeleteSpecificationBase<SqlUpdateSpecification>
        {
        #region ctor{IServiceProvider,SqlUpdateSpecification}
        public SqlScriptUpdateSpecification(IServiceProvider context,SqlUpdateSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }