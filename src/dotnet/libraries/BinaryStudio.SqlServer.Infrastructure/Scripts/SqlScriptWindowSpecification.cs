using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptWindowSpecification : SqlScriptCodeObject<SqlWindowSpecification>
        {
        public SqlWindowFrame WindowFrame {get{return Source.WindowFrame; }}

        #region ctor{IServiceProvider,SqlWindowSpecification}
        public SqlScriptWindowSpecification(IServiceProvider context,SqlWindowSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }