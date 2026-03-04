using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal abstract class SqlScriptModuleOption<T> : SqlScriptCodeObject<T>
        where T : SqlModuleOption
        {
        public SqlModuleOptionType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptModuleOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }