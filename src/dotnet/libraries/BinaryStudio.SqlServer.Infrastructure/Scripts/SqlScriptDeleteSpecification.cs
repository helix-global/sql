using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDeleteSpecification : SqlScriptUpdateDeleteSpecificationBase<SqlDeleteSpecification>
        {
        #region ctor{IServiceProvider,SqlDeleteSpecification}
        public SqlScriptDeleteSpecification(IServiceProvider context,SqlDeleteSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }